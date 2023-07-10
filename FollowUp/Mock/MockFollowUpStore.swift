//
//  MockFollowUpStore.swift
//  FollowUp
//
//  Created by Aaron Baw on 30/12/2021.
//

import Foundation

class MockFollowUpStore: FollowUpStoring {
    var contacts: [any Contactable] = []
    
    func numberOfContacts(_ searchPredicate: NewContactSearchPredicate, completion: @escaping (Int?) -> Void) {
        switch searchPredicate {
        case let .metWithinTimeframe(timeFrame): return completion(self.contacts.filter { $0.relativeDateGrouping == timeFrame }.count)
        case .thatAreNew: return completion(self.contacts.filter(\.isNew).count)
        }
    }
    
    var dailyFollowUpGoal: Int? = nil
    var tagSearchQuery: String = ""
    var selectedTagSearchTokens: [Tag] = []
    var contactSearchQuery: String = ""
    var settings: FollowUpSettings = .init()
    
    func updateWithFetchedContacts(_ contacts: [any Contactable]) {
        //
    }

    // MARK: Codable

    enum CodingKeys: CodingKey {
        case contacts
    }

    func contact(forID contactID: ContactID) -> (any Contactable)? {
        self.contacts.first(where: { $0.id == contactID })
    }
    
    func set(tagSearchQuery searchQuery: String) {
        self.tagSearchQuery = searchQuery
    }
    
    func set(selectedTagSearchTokens tagSearchTokens: [Tag]) {
        self.selectedTagSearchTokens = tagSearchTokens
    }
    
    func set(contactSearchQuery searchQuery: String) {
        self.contactSearchQuery = searchQuery
    }

//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
////        try container.encode([Contact].self, forKey: .contacts)
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.contacts = try container.decode([Contact].self, forKey: .contacts)
//    }

    init(numberOfContacts: Int = 5) {
        self.contacts = (0...numberOfContacts).map { _ in MockedContact() }
    }
    
}

// MARK: - Mock Static Property
extension FollowUpStoring where Self == MockFollowUpStore {
    static func mocked(withNumberOfContacts numberOfContacts: Int = 5) -> MockFollowUpStore {
        let followUpStore = MockFollowUpStore()
        followUpStore.contacts = (0...numberOfContacts).map { MockedContact(id: $0.description) }
        return followUpStore
    }
}
