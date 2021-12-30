//
//  FollowUpStore.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/12/2021.
//

import Collections
import Combine
import Foundation
import SwiftUI

protocol FollowUpStoring: Codable {
    var contacts: [Contactable] { get }
    var highlightedContacts: [Contactable] { get }
    var followUpContacts: [Contactable] { get }

    mutating func updateWithFetchedContacts(_ contacts: [Contactable])
    func contact(forID contactID: ContactID) -> Contactable?
}

// MARK: - Default Implementations
extension FollowUpStoring {
    var highlightedContacts: [Contactable] { contacts.filter(\.highlighted) }
    var followUpContacts: [Contactable] { contacts.filter(\.containedInFollowUps) }
}

struct FollowUpStore: FollowUpStoring, RawRepresentable {
    
    // MARK: - Stored Properties
    private var contactDictionary: [String: Contact] = [:] {
        didSet {
//            self.updateHighlightedAndFollowUps()
            self.contacts = contactDictionary.values.map { $0 }
        }
    }
    var contacts: [Contactable] = []
    private var lastFetchedContacts: Date?

    // MARK: - Static Properties
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()

    // MARK: - Methods
    mutating func updateWithFetchedContacts(_ contacts: [Contactable]) {
        let mapped = contacts
            .map(\.concrete)
            .mappedToDictionary(by: \.id)
        self.contactDictionary.merge(mapped, uniquingKeysWith: { first, second in
            first.lastInteractedWith ?? .distantPast
                >
            second.lastInteractedWith ?? .distantPast
            ? first
            : second
        })
        self.lastFetchedContacts = .now
    }

//    private mutating func updateHighlightedAndFollowUps() {
//        self.highlightedContacts = contacts.filter(\.highlighted)
//        self.followUpContacts = contacts.filter(\.containedInFollowUps)
//    }

    func contact(forID contactID: ContactID) -> Contactable? {
        self.contactDictionary[contactID]
    }

    init() {
        
    }

    // MARK: - CodingKeys
    enum CodingKeys: CodingKey {
        case contactDictionary
        case lastFetchedContacts
    }

    // MARK: - Codable Conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contactDictionary, forKey: .contactDictionary)
        try container.encode(lastFetchedContacts, forKey: .lastFetchedContacts)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contactDictionary = try container.decode([String:Contact].self, forKey: .contactDictionary)
        self.lastFetchedContacts = try container.decodeIfPresent(Date.self, forKey: .lastFetchedContacts)
        self.contacts = self.contactDictionary.values.map { $0 }
    }

    // MARK: - RawRepresentable Conformance
    var rawValue: String {
        guard
            let data = try? Self.encoder.encode(self),
            let string = String(data: data, encoding: .utf8)
        else { return .defaultFollowUpStoreString }
        return string
    }

    init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let followUpStore = try? Self.decoder.decode(FollowUpStore.self, from: data)
        else { return nil }
        self.contactDictionary = followUpStore.contactDictionary
        self.lastFetchedContacts = followUpStore.lastFetchedContacts
    }
}

fileprivate extension String {
    static var defaultFollowUpStoreString: String {
        """
        {
            "contacts": []
        }
        """
    }
}
