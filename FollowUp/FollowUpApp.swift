//
//  FollowUpApp.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Contacts
import SwiftUI

@main
struct FollowUpApp: App {

    // MARK: - State Objects
    @StateObject var followUpManager: FollowUpManager = .init()

    // MARK: - Static Properties
    static var decoder: JSONDecoder = .init()
    static var encoder: JSONEncoder = .init()
    static var serialWriteQueue: DispatchQueue = .init(label: "com.ventr.write.UserDefaults", qos: .background)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(followUpManager)
                .environmentObject(followUpManager.store)
            #if DEBUG
                .onAppear {
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                }
            #endif
        }
    }
}
