//
//  EnvironmentKey+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 14/10/2021.
//

import Foundation
import SwiftUI

// MARK: - Custom Environment Keys
struct ContactsInteractorKey: EnvironmentKey {
    static let defaultValue: ContactsInteractor = ContactsInteractor()
}

// MARK: - EnvironmentValues Extensions
extension EnvironmentValues {
    var contactsInteractor: ContactsInteractor {
        get { self[ContactsInteractorKey.self] }
        set { self[ContactsInteractorKey.self] = newValue }
    }
}
