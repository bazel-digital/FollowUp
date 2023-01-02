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

protocol FollowUpStoring: ObservableObject {
    var contacts: [any Contactable] { get }
    var highlightedContacts: [any Contactable] { get }
    var followUpContacts: [any Contactable] { get }
    var followedUpToday: Int { get }
    var dailyFollowUpGoal: Int? { get }

    func updateWithFetchedContacts(_ contacts: [any Contactable])
    func contact(forID contactID: ContactID) -> (any Contactable)?
}

// MARK: - Default Implementations
extension FollowUpStoring {
    var highlightedContacts: [any Contactable] { contacts.filter(\.highlighted) }
    var followUpContacts: [any Contactable] { contacts.filter(\.containedInFollowUps) }
    var followedUpToday: Int { contacts.filter(\.hasBeenFollowedUpToday).count }
}

extension ObjectId: _MapKey { }

class FollowUpStore: FollowUpStoring, ObservableObject {
    
    // MARK: - Stored Properties
    var dailyFollowUpGoal: Int? = 10
    var lastFetchedContacts: Date = .distantPast

    // This exposes variables which take the Realm Contacts, merge them with those from the device, and broadcast them to the rest of the app.
    @Published var contacts: [any Contactable] = []
    private var contactsDictionary: [ContactID: any Contactable] = [:] {
        didSet {
            self.contacts = self.contactsDictionary.values.map { $0 }
        }
    }
    
    // MARK: - Realm Properties
    // We subscribe to this to observe changes to the contacts within the Realm DB.
    var contactsResults: Results<Contact>? {
        didSet {
            self.mergeWithContactsDictionary(contacts: contactsResults?.array ?? [])
        }
    }
    var contactsNotificationToken: NotificationToken?
    private var realm: Realm?

    // MARK: - Static Properties
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()
    
    init(realm: Realm? = nil) {
        self.realm = realm
        self.configureObserver()
    }

    // MARK: - Methods
    func updateWithFetchedContacts(_ contacts: [any Contactable]) {
        guard let realm = realm else { return }
        
        self.mergeWithContactsDictionary(contacts: contacts)
        
        let contactIDsToBeUpdated: [ContactID] = contacts.map(\.id)
        let updatedContacts = self.contactsDictionary.values.filter { contactIDsToBeUpdated.contains($0.id) }
        
        do {
            try realm.write {
                realm.add(updatedContacts, update: .modified)
                self.lastFetchedContacts = .now
            }
        } catch {
            print("Unable to update Realm DB with \(contacts.count) newly fetched contacts: \(error.localizedDescription)")
        }
    }
    
    func mergeWithContactsDictionary(contacts: [any Contactable]) {
        self.contactsDictionary.merge(contacts.mappedToDictionary(by: \.id)) { first, second in
            // Check to see when we last interacted with a contact. We use the most recently interacted with version.
            // TODO: We should always start with the last interacted with contact, and then update all the other values (e.g. name, email, phone number, etc).
            (first.lastInteractedWith ?? .distantPast) > (second.lastInteractedWith ?? .distantPast) ? first : second
        }
    }


    func contact(forID contactID: ContactID) -> (any Contactable)? {
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
            self?.contactsResults = observedContacts
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
