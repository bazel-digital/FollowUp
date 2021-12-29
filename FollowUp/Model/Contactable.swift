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

protocol Contactable {
    var id: String { get }
    var name: String { get }
    var phoneNumber: PhoneNumber? { get }
    var email: String? { get }
    var thumbnailImage: UIImage? { get }
    var note: String? { get set }
    var followUps: Int { get set }
    var createDate: Date { get }
    var highlighted: Bool { get }
    var containedInFollowUps: Bool { get }

    // MARK: - Interaction Indicators
    var lastFollowedUp: Date? { get set }
    var hasBeenFollowedUpToday: Bool { get }
    var lastInteractedWith: Date? { get set }
    var hasInteractedWithToday: Bool { get }
}

struct Contact: Contactable, Hashable, Identifiable {
    
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
    let createDate: Date
    
    // MARK: - Interactive Properties
    var followUps: Int { didSet { lastFollowedUp = .now } }
    var lastFollowedUp: Date? { didSet { lastInteractedWith = .now } }
    var highlighted: Bool { didSet { lastInteractedWith = .now } }
    var containedInFollowUps: Bool { didSet { lastInteractedWith = .now } }
    var note: String? { didSet { lastInteractedWith = .now } }

    // MARK: - Interaction Indicators
    var lastInteractedWith: Date?

    // MARK: - Initialisation
    init(
        id: String = UUID().uuidString,
        name: String,
        phoneNumber: PhoneNumber?,
        email: String?,
        thumbnailImage: UIImage?,
        note: String? = nil,
        followUps: Int = 0,
        createDate: Date,
        lastFollowedUp: Date? = nil,
        highlighted: Bool = false,
        containedInFollowUps: Bool = false,
        lastInteractedWith: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.thumbnailImage = thumbnailImage
        self.note = note
        self.followUps = followUps
        self.createDate = createDate
        self.lastFollowedUp = lastFollowedUp
        self.highlighted = highlighted
        self.containedInFollowUps = containedInFollowUps
        self.lastInteractedWith = lastInteractedWith
    }
}

// MARK: - Convenience Initialisers and Conversions
extension Contact {
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

    init(from contact: Contactable){
        self.id = contact.id
        self.name = contact.name
        self.phoneNumber = contact.phoneNumber
        self.email = contact.email
        self.thumbnailImage = contact.thumbnailImage
        self.note = contact.note
        self.followUps = contact.followUps
        self.createDate = contact.createDate
        self.lastFollowedUp = contact.lastFollowedUp
        self.lastInteractedWith = contact.lastInteractedWith
        self.highlighted = contact.highlighted
        self.containedInFollowUps = contact.containedInFollowUps
    }
}

// MARK: - Conversion to Concrete type Convenience
extension Contactable {
    var concrete: Contact {
        Contact.init(from: self)
    }
}

// MARK: - Grouping Extension
extension Contactable {
    var dateGrouping: DateGrouping {
        DateGrouping.allCases.first(where: { grouping in
            grouping.dateInterval?.contains(self.createDate) == true
        }) ?? .previous
    }
}

// MARK: - Codable Conformance
extension Contact: Codable {

    enum CodingKeys: CodingKey {
        case id, name, phoneNumber, thumbnailImage, note, followUps, createDate, lastFollowedUp, highlighted, containedInFollowUps, lastInteractedWith
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.phoneNumber = try container.decodeIfPresent(PhoneNumber.self, forKey: .phoneNumber)
        self.thumbnailImage = try container.decodeIfPresent(Data.self, forKey: .thumbnailImage)?.uiImage
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.followUps = try container.decode(Int.self, forKey: .followUps)
        self.createDate = try container.decode(Date.self, forKey: .createDate)
        self.lastFollowedUp = try container.decodeIfPresent(Date.self, forKey: .lastFollowedUp)
        self.highlighted = try container.decode(Bool.self, forKey: .highlighted)
        self.containedInFollowUps = try container.decode(Bool.self, forKey: .containedInFollowUps)
        self.lastInteractedWith = try container.decodeIfPresent(Date.self, forKey: .lastInteractedWith)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(thumbnailImage?.pngData(), forKey: .thumbnailImage)
        try container.encode(note, forKey: .note)
        try container.encode(followUps, forKey: .followUps)
        try container.encode(createDate, forKey: .createDate)
        try container.encode(lastFollowedUp, forKey: .lastFollowedUp)
        try container.encode(highlighted, forKey: .highlighted)
        try container.encode(containedInFollowUps, forKey: .containedInFollowUps)
        try container.encode(lastInteractedWith, forKey: .lastInteractedWith)
    }

}

// MARK: - Computed Properties
extension Contactable {
    private var firstName: String { name.split(separator: " ").first?.capitalized ?? name }

    private var lastName: String { name.split(separator: " ").last?.capitalized ?? "" }

    var initials: String {
        (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
    }

    var hasBeenFollowedUpToday: Bool {
        guard let lastFollowedUpDate = self.lastFollowedUp else { return false}
        return Calendar.current.isDateInToday(lastFollowedUpDate)
    }

    var hasInteractedWithToday: Bool {
        guard let lastInteractionDate = self.lastInteractedWith else { return false }
        return Calendar.current.isDateInToday(lastInteractionDate)
    }
}
