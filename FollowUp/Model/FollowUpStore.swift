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
    var settings: FollowUpSettings { get }

    func updateWithFetchedContacts(_ contacts: [any Contactable])
    func contact(forID contactID: ContactID) -> (any Contactable)?
    func numberOfContacts(_ searchPredicate: NewContactSearchPredicate, completion: @escaping (Int?) -> Void)
    func set(contactSearchQuery searchQuery: String)
    func set(tagSearchQuery searchQuery: String)
    func set(selectedTagSearchTokens tagSearchTokens: [Tag])
}

// MARK: - Default Implementations
extension FollowUpStoring {
    // This is being performed on the main thread, which would make sense why there is lag as it has to recalculate all the follow ups 
    var highlightedContacts: [any Contactable] { contacts.filter(\.highlighted) }
    var followUpContacts: [any Contactable] { contacts.filter(\.containedInFollowUps) }
    var followedUpToday: Int { contacts.filter(\.hasBeenFollowedUpToday).count }
}

extension ObjectId: _MapKey { }

class FollowUpStore: FollowUpStoring, ObservableObject {
    
    // MARK: - Stored Properties
    var lastFetchedContacts: Date = .distantPast
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Stored Properties (Search Queries)
    @Published private var contactSearchQuery: String = ""
    @Published private var tagSearchQuery: String = ""
    
    var settings: FollowUpSettings = .init()
    private let backgroundQueue: DispatchQueue = .init(label: "com.bazel.followup.store.background", qos: .background)

    // MARK: - Stored Properties (Published)
    // This exposes variables which take the Realm Contacts, merge them with those from the device, and broadcast them to the rest of the app.
    @Published var contacts: [any Contactable] = [] { didSet { self.sortedContacts = self.computeSortedContacts() } }
    
    // Cached view properties
    @Published var sortedContacts: [any Contactable] = [] {
        didSet { self.contactSections = self.computeContactSections() }
    }
    @Published var contactSections: [ContactSection] = []
    
    private var contactsDictionary: [ContactID: any Contactable] = [:] {
        didSet {
            self.contacts = self.contactsDictionary.values.map { $0 }
        }
    }
    
    // Tags
    @Published var tagSuggestions: [Tag] = []
    @Published var allTags: [Tag] = []
    @Published var selectedTagSearchTokens: [Tag] = []
    private var tagsResults: Results<Tag>? { didSet { self.allTags = tagsResults?.array ?? [] } }
    
    // MARK: - Realm Properties
    // We subscribe to this to observe changes to the contacts within the Realm DB.
    var contactsResults: Results<Contact>? {
        didSet {
            self.mergeWithContactsDictionary(contacts: contactsResults?.array ?? [])
        }
    }
    private var contactsNotificationToken: NotificationToken?
    private var tagsNotificationToken: NotificationToken?
    private var realm: Realm?

    // MARK: - Static Properties
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()
    
    init(realm: Realm? = nil) {
        self.realm = realm
        self.loadSettingsFromRealm()
        self.configureContactsObserver()
        self.configureTagsObserver()
        
        // Register for changes in the search queries, then recalculate the results with a debounce.
        $contactSearchQuery
            .debounce(for: Constant.Search.contactSearchDebounce, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                self.sortedContacts = self.computeSortedContacts()
            })
            .store(in: &cancellables)
        
        $tagSearchQuery
            .debounce(for: Constant.Search.tagSearchDebounce, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                self.tagSuggestions = self.computeFilteredTags()
            })
            .store(in: &cancellables)
        
        $selectedTagSearchTokens
            .debounce(for: Constant.Search.tagSearchDebounce, scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                self.sortedContacts = self.computeSortedContacts()
            })
            .store(in: &cancellables)
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
            assertionFailurePreviewSafe("Unable to update Realm DB with \(contacts.count) newly fetched contacts: \(error.localizedDescription)")
        }
    }
    
    
    func mergeWithContactsDictionary(contacts: [any Contactable]) {
        self.contactsDictionary.merge(contacts.mappedToDictionary(by: \.id)) { first, second in
            // Check to see when we last interacted with a contact. We use the most recently interacted with version.
            // TODO: We should always start with the last interacted with contact, and then update all the other values (e.g. name, email, phone number, etc).
            (first.lastInteractedWith ?? .distantPast) > (second.lastInteractedWith ?? .distantPast) ? first : second
        }
    }
    
    func numberOfContacts(_ searchPredicate: NewContactSearchPredicate, completion: @escaping (Int?) -> Void) {
        // This needs to take place on a background thread, as it is typically performed by a background task.
        DispatchQueue.global(qos: .background).async {

            do {
                let backgroundRealm = try Realm(configuration: .defaultConfiguration)
                let contacts = backgroundRealm.objects(Contact.self)
                
                switch searchPredicate {
                case let .metWithinTimeframe(timeFrame):
                    // This background task tends to fail when the contact list is relatively large (in the 100s), due to the processing time required to evaluate and compare each individual contact. We sort the contacts and prefix the number of contacts to something reasonable (e.g. 100) to prevent the task from failing.
                    let filteredContacts = contacts
                        .sorted(by: \.createDate, ascending: false)
                        .prefix(upTo: Constant.Processing.numberOfContactsToProcessInBackground)
                        .filter({
                        $0.relativeDateGrouping == timeFrame
                    })
                    
                    return completion(filteredContacts.count)
                case .thatAreNew:
                    let filteredContacts = contacts
                        .prefix(upTo: Constant.Processing.numberOfContactsToProcessInBackground)
                        .filter(\.isNew)
                    return completion(filteredContacts.count)
                }
                
                
            } catch {
                Log.error("Could not initialise background realm to count number of new contacts: \(error.localizedDescription)")
                return completion(nil)
            }

        }
    }

//    func numberOfContacts(metWithinTimeframe timeFrame: RelativeDateGrouping, completion: @escaping (Int?) -> Void) {
//        // This needs to take place on a background thread, as it is typically performed by a background task.
//        DispatchQueue.global(qos: .background).async {
//
//            do {
//                let backgroundRealm = try Realm(configuration: .defaultConfiguration)
//                let contacts = backgroundRealm.objects(Contact.self)
//                
//                // This background task tends to fail when the contact list is relatively large (in the 100s), due to the processing time required to evaluate and compare each individual contact. We sort the contacts and prefix the number of contacts to something reasonable (e.g. 100) to prevent the task from failing.
//                let filteredContacts = contacts
//                    .sorted(by: \.createDate, ascending: false)
//                    .prefix(upTo: Constant.Processing.numberOfContactsToProcessInBackground)
//                    .filter({
//                    $0.relativeDateGrouping == timeFrame
//                })
//                return completion(filteredContacts.count)
//            } catch {
//                Log.error("Could not initialise background realm to count number of new contacts: \(error.localizedDescription)")
//                return completion(nil)
//            }
//
//        }
//    }
    
    func contact(forID contactID: ContactID) -> (any Contactable)? {
        guard
            let realm = realm,
            let contact = realm.object(ofType: Contact.self, forPrimaryKey: contactID)
        else {
            assertionFailurePreviewSafe("Unable to find contact for ID \(contactID)")
            return nil
        }

        return contact
    }
    
    func set(contactSearchQuery searchQuery: String) {
        self.contactSearchQuery = searchQuery
    }
    
    func set(tagSearchQuery searchQuery: String) {
        self.tagSearchQuery = searchQuery
    }
    
    /// Called by the Contact List view when a Tag is selected and to be used for filtering.
    func set(selectedTagSearchTokens tagSearchTokens: [Tag]) {
        self.selectedTagSearchTokens = tagSearchTokens
    }
    
    // MARK: - Methods (View Model)
    private func computeSortedContacts() -> [any Contactable] {
        contacts
        .filter { contact in
            guard !self.contactSearchQuery.isEmpty || !self.selectedTagSearchTokens.isEmpty else { return true }
            return contact.name.fuzzyMatch(self.contactSearchQuery) && contact.tags.contains(self.selectedTagSearchTokens)
        }
        .sorted(by: \.createDate)
        .reversed()
    }
    
    private func computeContactSections() -> [ContactSection] {
        sortedContacts
            .grouped(by: settings.contactListGrouping.keyPath)
            .map { grouping, contacts in
                .init(
                    contacts: contacts
                        .sorted(by: \.createDate)
                        .reversed(),
                    grouping: grouping
                )
            }
            .sorted(by: \.grouping)
            .reversed()
    }
    
    private func computeFilteredTags() -> [Tag] {
        guard !self.tagSearchQuery.isEmpty else { return self.allTags }
        return self.allTags.filter { $0.title.fuzzyMatch(self.tagSearchQuery.trimmingWhitespace()) }
    }
    
    // MARK: - Realm Configuration
    func configureContactsObserver() {
        guard let realm = realm else {
            assertionFailurePreviewSafe("Could not find realm in order to configure contacts observer.")
            return
        }
        let observedContacts = realm.objects(Contact.self)
        self.contactsNotificationToken = observedContacts.observe { [weak self] _ in
            self?.contactsResults = observedContacts
        }
    }
    
    private func configureTagsObserver() {
        guard let realm = realm else {
            assertionFailurePreviewSafe("Could not find realm in order to configure tags observer.")
            return
        }
        let observedTags = realm.objects(Tag.self)
        self.tagsNotificationToken = observedTags.observe { [weak self] _ in
            self?.tagSuggestions = []
            self?.tagsResults = observedTags
        }
    }
    
//    func configureObserver() {
//        guard let realm = realm else {
//            assertionFailurePreviewSafe("Could not find realm in order to configure contacts observer.")
//            return
//        }
//        let observedContacts = realm.objects(Contact.self)
//        self.contactsNotificationToken = observedContacts.observe { [weak self] _ in
//            self?.contactsResults = observedContacts
//        }
//    }
    
//    func configureObserver() {
//        guard let realm = realm else {
//            assertionFailurePreviewSafe("Could not find realm in order to configure contacts observer.")
//            return
//        }
//        let observedContacts = realm.objects(Contact.self)
//        self.contactsNotificationToken = observedContacts.observe { [weak self] changes in
//
//            self?.contactsResults = observedContacts
//            switch changes {
//            case .initial:
//                self?.contacts = observedContacts.array
//                // Results are now populated and can be accessed without blocking the UI
////            self?.contacts = observedContacts.array
//            case .update(let results, let deletions, let insertions, let modifications):
//
////                print(results)
//
//                insertions.forEach { index in
//                    self?.contacts.insert(results[index], at: index)
//                }
//
//                modifications.forEach { index in
//                    self?.contacts[index] = results[index]
//                }
//
//                // Check this is working as expected.
//                self?.contacts.remove(atOffsets: .init(deletions))
//                Log.info("Modifications \(modifications)")
//                Log.info("Deletions \(deletions)")
//                Log.info("Insertions \(insertions)")
//
//
//            case .error(let error):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(error)")
//            }
//
//
//        }
//    }
    
    func loadSettingsFromRealm() {
        if let followUpSettings = self.realm?.objects(FollowUpSettings.self).first {
            self.settings = followUpSettings
            Log.info("Loaded FollowUpSettings from realm.")
        } else {
            Log.warn("FollowUpSettings not found in realm. Creating a new instance.")
            let followUpSettings = FollowUpSettings()
            do {
                try self.realm?.write {
                    self.realm?.add(followUpSettings)
                    Log.info("Added instance of FollowUpSettings to realm.")
                    self.settings = followUpSettings
                }
            } catch {
                assertionFailurePreviewSafe("Could not write new instance of FollowUpSettings to realm. \(error.localizedDescription)")
            }
        }
    }

    // MARK: - CodingKeys
    enum CodingKeys: CodingKey {
        case contactDictionary
        case lastFetchedContacts
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

/// Persistent App Storage container.
final class FollowUpManager: ObservableObject {

    // MARK: - Private Stored Properties
    @Persisted(Constant.Key.followUpStore) var store: FollowUpStore = .init() {
        didSet { self.objectWillChange.send() }
    }
    public lazy var contactsInteractor: ContactsInteracting = ContactsInteractor()
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Public Methods
    public func fetchContacts() async {
        await self.contactsInteractor.fetchContacts()
    }

    // MARK: - Initialization
    init() {
        self.subscribeForNewContacts()
        self.objectWillChange.send()
    }

    // MARK: - Methods
    private func subscribeForNewContacts() {
        self.contactsInteractor
            .contactsPublisher
            .sink(receiveValue: { newContacts in
                self.store.updateWithFetchedContacts(newContacts)
            })
            .store(in: &self.subscriptions)
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

fileprivate extension String {
    static var defaultFollowUpStoreString: String {
        """
        {
            "contacts": []
        }
        """
    }
}
