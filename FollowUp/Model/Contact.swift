//
//  Contact.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import AddressBook
import Contacts
import Foundation
import UIKit

protocol Contact {
    var id: String { get }
    var name: String { get }
    var phoneNumber: PhoneNumber? { get }
    var email: String? { get }
    var thumbnailImage: UIImage? { get }
    var note: String { get }
    var followUps: Int { get set }
    var createDate: Date { get }
    var highlighted: Bool { get }
    var containedInFollowUps: Bool { get }
}

struct RecentContact: Contact {

    // MARK: - Enums
    enum ImageFormat {
        case thumbnail
        case full
    }

    // MARK: - Stored Properties
    let id: String
    let name: String
    var phoneNumber: PhoneNumber?
    var email: String?
    let thumbnailImage: UIImage?
    var note: String
    var followUps: Int
    let createDate: Date
    var highlighted: Bool
    var containedInFollowUps: Bool

    // MARK: - Initialisation
    init(
        id: String = UUID().uuidString,
        name: String,
        phoneNumber: PhoneNumber?,
        email: String?,
        thumbnailImage: UIImage?,
        note: String,
        followUps: Int = 0,
        createDate: Date,
        highlighted: Bool = false,
        containedInFollowUps: Bool = false
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.thumbnailImage = thumbnailImage
        self.note = note
        self.followUps = followUps
        self.createDate = createDate
        self.highlighted = highlighted
        self.containedInFollowUps = containedInFollowUps
    }
}

// MARK: - Convenience Initialisers
extension RecentContact {
    init(from contact: CNContact){
        self.id = contact.identifier
        self.name = [contact.givenName, contact.familyName].joined(separator: " ")
        self.thumbnailImage = (contact.thumbnailImageData ?? contact.thumbnailImageData)?.uiImage
        self.note = ""
        self.followUps = 0
        // ⚠️ TODO: Update this to use the provided dates from CNContact.
        self.createDate = Date()
        self.highlighted = false
        self.containedInFollowUps = false
    }
}

// MARK: - Grouping Extension
extension Contact {
    var dateGrouping: DateGrouping {
        DateGrouping.allCases.first(where: { grouping in
            grouping.dateInterval?.contains(self.createDate) == true
        }) ?? .previous
    }
}

// MARK: - Convenience Computed Properties
extension Contact {
    private var firstName: String { name.split(separator: " ").first?.capitalized ?? name }

    private var lastName: String { name.split(separator: " ").last?.capitalized ?? "" }

    var initials: String {
        (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
    }
}
