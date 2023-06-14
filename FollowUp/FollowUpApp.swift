//
//  FollowUpApp.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Contacts
import SwiftUI
import UserNotifications

@main
struct FollowUpApp: App {

    // MARK: - State Objects
    @StateObject var followUpManager: FollowUpManager = .init()
    
    // MARK: - Environment Objects
    @Environment(\.scenePhase) var scenePhase

    // MARK: - Static Properties
    static var decoder: JSONDecoder = .init()
    static var encoder: JSONEncoder = .init()
    static var serialWriteQueue: DispatchQueue = .init(label: "com.ventr.write.UserDefaults", qos: .background)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(followUpManager)
                .environmentObject(followUpManager.store)
                .environmentObject(followUpManager.store.settings)
                .onAppear(perform: self.followUpManager.configureNotifications)
            #if DEBUG
                .onAppear {
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                }
            #endif
        }
        .backgroundTask(.appRefresh(Constant.Processing.followUpRemindersTaskIdentifier)) { task in
            // Freeze the current realm so that we can access it from a background thread.
            await self.followUpManager.handleScheduledNotificationsBackgroundTask(nil)
        }
    }
}
