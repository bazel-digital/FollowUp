//
//  MockContactInteractor.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

class MockContactsInteractor: ContactsInteracting, ObservableObject {
    @Published var contacts: [Contact] = []
    
    var contactsPublisher: Published<[Contact]>.Publisher {
        $contacts
    }

    private var addToContactAmount: Int

    init(
        addToContactAmount: Int = 10
    ) {
        self.addToContactAmount = addToContactAmount
        self.contacts = (0...addToContactAmount).map { _ in MockedContact() }
    }

    func fetchContacts() async {
        self.contacts.append(contentsOf: generateContacts(withCount: 10))
    }

    private func generateContacts(withCount count: Int) -> [Contact] {
        (0...count).map { _ in MockedContact() }
    }
    
}
