//
//  FollowUpStore.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/12/2021.
//

import Collections
import Combine
import Foundation

/// Persistent App Storage container.
class FollowUpStore: Codable, ObservableObject, RawRepresentable {

    // MARK: - Public Stored Properties
    @Published var contacts: OrderedSet<Contact> = .init() {
        didSet {
            self.updateHighlightedAndFollowUps()
        }
    }

    lazy var highlightedContacts: [Contact] = contacts.filter(\.highlighted)
    lazy var followUpContacts: [Contact] = contacts.filter(\.containedInFollowUps)

    // MARK: - Private Stored Properties
    // TODO: Expose this separately as an \.Environment key.
    public var contactsInteractor: ContactsInteracting = ContactsInteractor()
    private var lastFetchedContacts: Date?
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Static Properties
    private static var encoder = JSONEncoder()
    private static var decoder = JSONDecoder()

    // MARK: - Public Methods
    public func fetchContacts() async {
        await self.contactsInteractor.fetchContacts()
    }

    // MARK: - Private Methods
    private func updateHighlightedAndFollowUps() {
        self.highlightedContacts = contacts.filter(\.highlighted)
        self.followUpContacts = contacts.filter(\.containedInFollowUps)
    }

    func getHighlightedContacts() -> [Contact] {
        contacts.filter(\.highlighted)
    }

    func getFollowUpContacts() -> [Contact] {
        contacts.filter(\.containedInFollowUps)
    }

    // MARK: - Initialization
    init() {
        self.contactsInteractor
            .contactsPublisher
            .sink(receiveValue: { contacts in
                self.contacts.append(contentsOf: contacts.map(\.concrete))
            })
            .store(in: &subscriptions)
    }

    // MARK: - CodingKeys
    enum CodingKeys: CodingKey {
        case contacts
        case lastFetchedContacts
    }

    // MARK: - Codable Conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contacts, forKey: .contacts)
        try container.encode(lastFetchedContacts, forKey: .lastFetchedContacts)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.contacts = try container.decode(OrderedSet<Contact>.self, forKey: .contacts)
        self.lastFetchedContacts = try container.decodeIfPresent(Date.self, forKey: .lastFetchedContacts)
    }

    // MARK: - RawRepresentable Conformance
    var rawValue: String {
        guard
            let data = try? Self.encoder.encode(self),
            let string = String(data: data, encoding: .utf8)
        else { return .defaultFollowUpStoreString }
        return string
    }

    required init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let followUpStore = try? Self.decoder.decode(FollowUpStore.self, from: data)
        else { return nil }
        self.contacts = followUpStore.contacts
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
