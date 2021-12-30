//
//  FollowUpManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 30/12/2021.
//

import Combine
import Foundation

final class FollowUpManager: ObservableObject {

    // MARK: - Private Stored Properties
    @Persisted(Constant.Key.followUpStore) var store: FollowUpStore = .init() {
        didSet { self.objectWillChange.send() }
    }
    public var contactsInteractor: ContactsInteracting = ContactsInteractor()
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Public Methods
    public func fetchContacts() async {
        await self.contactsInteractor.fetchContacts()
    }

    // MARK: - Initialization
    init(
        contactsInteractor: ContactsInteracting? = nil,
        store: FollowUpStore? = nil
    ) {
        if let contactsInteractor = contactsInteractor {
            self.contactsInteractor = contactsInteractor
        }

        if let store = store {
            self.store = store
        }

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
