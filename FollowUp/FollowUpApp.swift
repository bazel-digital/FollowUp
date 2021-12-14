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
    @AppStorage(Constant.Key.followUpStore) var followUpStore: FollowUpStore = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(followUpStore)
        }
    }
}
