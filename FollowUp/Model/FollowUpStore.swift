//
//  FollowUpStore.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/12/2021.
//

import Collections
import Foundation

/// Persistent App Storage container.
struct FollowUpStore {

    // MARK: - Stored Properties
    var contacts: OrderedSet<Contact> {
        didSet {
            self.updateHighlightedAndFollowUps()
        }
    }

    lazy var highlightedContacts: [Contactable] = contacts.filter(\.highlighted)
    lazy var followUpContacts: [Contactable] = contacts.filter(\.containedInFollowUps)

    // MARK: - Methods
    mutating private func updateHighlightedAndFollowUps() {
        self.highlightedContacts = contacts.filter(\.highlighted)
        self.followUpContacts = contacts.filter(\.containedInFollowUps)
    }

    private func getHighlightedContacts() -> [Contactable] {
        contacts.filter(\.highlighted)
    }

    private func getFollowUpContacts() -> [Contactable] {
        contacts.filter(\.containedInFollowUps)
    }

}
