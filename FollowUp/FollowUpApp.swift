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
    @StateObject var contactsInteractor: ContactsInteractor = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contactsInteractor)
        }
    }
}
