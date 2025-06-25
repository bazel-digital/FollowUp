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
    @State private var errorIsPresented: Bool = false
    
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
//                .alert(item: $followUpManager.error, content: { error in
//                    Alert(
//                        title: Text("Unable To Generate Message"),
//                        message: Text(error.localizedDescription),
//                        dismissButton: .cancel()
//                    )
//                })
                .errorAlert(error: $followUpManager.error)
                .accentColor(.accent)
            #if DEBUG
                .onAppear {
                    Log.info(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                }
            #endif
        }
        .backgroundTask(.appRefresh(Constant.Processing.followUpRemindersTaskIdentifier)) { task in
            // Freeze the current realm so that we can access it from a background thread.
            await self.followUpManager.handleScheduledNotificationsBackgroundTask(nil)
        }
    }
}
