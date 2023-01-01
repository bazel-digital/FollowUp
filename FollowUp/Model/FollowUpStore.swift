//
//  FollowUpStore.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/12/2021.
//

import Collections
import Combine
import Foundation
import Realm
import RealmSwift
import SwiftUI

protocol FollowUpStoring {
    var contacts: [any Contactable] { get }
    var highlightedContacts: [any Contactable] { get }
    var followUpContacts: [any Contactable] { get }
    var followedUpToday: Int { get }
    var dailyFollowUpGoal: Int? { get }

    mutating func updateWithFetchedContacts(_ contacts: [any Contactable])
    func contact(forID contactID: ContactID) -> (any Contactable)?
}

// MARK: - Default Implementations
extension FollowUpStoring {
    var highlightedContacts: [any Contactable] { contacts.filter(\.highlighted) }
    var followUpContacts: [any Contactable] { contacts.filter(\.containedInFollowUps) }
    var followedUpToday: Int { contacts.filter(\.hasBeenFollowedUpToday).count }
}

extension ObjectId: _MapKey { }

class FollowUpStore: Object, ObjectKeyIdentifiable, FollowUpStoring {
    
    // MARK: - Stored Properties
//    var contactDictionary: RealmSwift.Map<String, Contact?> = .init() {
//        didSet {
//            self.contacts = contactDictionary.values.compactMap { $0 }
//        }
//    }
    @Persisted var dailyFollowUpGoal: Int? = 10
    @Persisted var lastFetchedContacts: Date
    
    @Published var _contacts: Results<Contact>?
    var contacts: [any Contactable] {
        self._contacts?.array ?? []
    }
    
    var contactsNotificationToken: NotificationToken?

    // MARK: - Static Properties
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()

    // MARK: - Methods
//    func updateWithFetchedContacts(_ contacts: [Contactable]) {
//        let mapped = contacts
//            .map(\.concrete)
//            .mappedToDictionary(by: \.contactID)
//
//        try? self.realm?.write {
//            self.contactDictionary.merge(mapped, uniquingKeysWith: { first, second in
//                first?.lastInteractedWith ?? .distantPast
//                >
//                second?.lastInteractedWith ?? .distantPast
//                ? first
//                : second
//            })
//            self.lastFetchedContacts = .now
//
//        }
//    }
    
    func updateWithFetchedContacts(_ contacts: [any Contactable]) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(contacts, update: .modified)
            }
        } catch {
            print("Unable to update Realm DB with \(contacts.count) newly fetched contacts: \(error.localizedDescription)")
        }
    }


    func contact(forID contactID: ContactID) -> (any Contactable)? {
//        self.contactDictionary[contactID] ?? nil
        guard
            let realm = realm,
            let contact = realm.object(ofType: Contact.self, forPrimaryKey: contactID)
        else {
            print("Unable to find contact for ID \(contactID)")
            return nil
        }

        return contact
    }
    
    func configureObserver() {
        guard let realm = realm else {
            print("Could not find realm in order to configure contacts observer.")
            return
        }
        let observedContacts = realm.objects(Contact.self)
        self.contactsNotificationToken = observedContacts.observe { [weak self] _ in
            self?._contacts = observedContacts
        }
    }

    // MARK: - CodingKeys
    enum CodingKeys: CodingKey {
        case contactDictionary
        case lastFetchedContacts
    }

    // MARK: - Codable Conformance
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(contactDictionary, forKey: .contactDictionary)
//        try container.encode(lastFetchedContacts, forKey: .lastFetchedContacts)
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.contactDictionary = try container.decode([ContactID:Contact].self, forKey: .contactDictionary)
//        self.lastFetchedContacts = try container.decodeIfPresent(Date.self, forKey: .lastFetchedContacts)
//        self.contacts = self.contactDictionary.values.map { $0 }
//    }

    // MARK: - RawRepresentable Conformance
//    var rawValue: String {
//        guard
//            let data = try? Self.encoder.encode(self),
//            let string = String(data: data, encoding: .utf8)
//        else { return .defaultFollowUpStoreString }
//        return string
//    }
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
