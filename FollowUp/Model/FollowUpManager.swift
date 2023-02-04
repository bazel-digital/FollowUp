//
//  FollowUpManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 30/12/2021.
//

import Combine
import Foundation
import RealmSwift

final class FollowUpManager: ObservableObject {

    // MARK: - Private Stored Properties
    
    var realm: Realm?

    // First, we check to see if a follow up store exists in our realm.
    // If one doesn't exist, then we create one and add it to the realm.
    // If a follow up store has been passed as an argument, than this supercedes any store that we find in the realm.
    var store: FollowUpStore

    var contactsInteractor: ContactsInteracting
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Initialization
    init(
        contactsInteractor: ContactsInteracting? = nil,
        store: FollowUpStore? = nil,
        realmName: String = "followUpStore"
    ) {
        // The Schema (and Realm object) needs to be initialised first, as this is referenced in order to fetch any existing FollowUpStores from the Realm DB.
        let realm = Self.initializeRealm()
        self.realm = realm
        self.contactsInteractor = contactsInteractor ?? ContactsInteractor(realm: realm)
        // First, we check to see if a follow up store exists in our realm.
        // If one doesn't exist, then we create one and add it to the realm.
        // If a follow up store has been passed as an argument, than this supercedes any store that we find in the realm.
        self.store = store ?? FollowUpStore(realm: realm)

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
    
    // MARK: - Realm Configuration
    static func initializeRealm(name: String = "followUpRealm") -> Realm? {
        
        // Get the document directory and create a file with the passed name
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let realmFileURL = documentDirectory?.appendingPathComponent("\(name).realm")
        let config = Realm.Configuration(fileURL: realmFileURL, schemaVersion: 0)
        Realm.Configuration.defaultConfiguration = config
        
        do {
            return try Realm()
        } catch {
            print("Could not open realm: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Fetches any existing FollowUpStores from Realm. If one does not exist, then one is created and returned.
//    func fetchFollowUpStoreFromRealm() -> FollowUpStore {
//
//        guard let realm = self.realm else {
//            assertionFailurePreviewSafe("Could not initialise FollowUpStore as Realm is nil.")
//            return .init()
//        }
//
//        if let followUpStore = realm.objects(FollowUpStore.self).first {
//            return followUpStore
//        } else {
//            let followUpStore: FollowUpStore = .init()
//            do {
//                try realm.write {
//                    realm.add(followUpStore)
//                }
//            } catch {
//                print("Could not add FollowUpStore to realm: \(error.localizedDescription)")
//            }
//            return followUpStore
//        }
//    }

}
