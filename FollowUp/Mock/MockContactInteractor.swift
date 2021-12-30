//
//  MockContactInteractor.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Combine
import Foundation

class MockContactsInteractor: ContactsInteracting, ObservableObject {
    @Published var contactSheet: ContactSheet?

    @Published var contacts: [Contactable] = []
    
    var contactsPublisher: AnyPublisher<[Contactable], Never> {
        $contacts.eraseToAnyPublisher()
    }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> {
        self.$contactSheet.eraseToAnyPublisher()
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

    private func generateContacts(withCount count: Int) -> [Contactable] {
        (0...count).map { _ in MockedContact() }
    }

    // MARK: - Public Methods

    func highlight(_ contact: Contactable) {
        
    }
    
    func unhighlight(_ contact: Contactable) {
        
    }
    
    func addToFollowUps(_ contact: Contactable) {
        
    }
    
    func removeFromFollowUps(_ contact: Contactable) {
        
    }
    
    func markAsFollowedUp(_ contact: Contactable) {
        
    }

    func displayContactSheet(_ contact: Contactable) {
        self.contactSheet = contact.sheet
    }

    func hideContactSheet() {
        self.contactSheet = nil
    }
    
}
