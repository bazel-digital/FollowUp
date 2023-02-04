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

    @Published var contacts: [any Contactable] = []
    
    @Published var state: ContactInteractorState = .fetchingContacts
    
    var contactsPublisher: AnyPublisher<[any Contactable], Never> {
        $contacts.eraseToAnyPublisher()
    }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> {
        self.$contactSheet.eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<ContactInteractorState, Never> {
        self.$state.eraseToAnyPublisher()
    }

    private var addToContactAmount: Int

    init(
        addToContactAmount: Int = 10
    ) {
        self.addToContactAmount = addToContactAmount
        self.contacts = (0...addToContactAmount).map { _ in MockedContact() }
    }

    func fetchContacts() {
        self.contacts.append(contentsOf: generateContacts(withCount: 10))
    }

    private func generateContacts(withCount count: Int) -> [any Contactable] {
        (0...count).map { _ in MockedContact() }
    }

    // MARK: - Public Methods

    func highlight(_ contact: any Contactable) {
        
    }
    
    func unhighlight(_ contact: any Contactable) {
        
    }
    
    func addToFollowUps(_ contact: any Contactable) {
        
    }
    
    func removeFromFollowUps(_ contact: any Contactable) {
        
    }
    
    func markAsFollowedUp(_ contact: any Contactable) {
        
    }

    func displayContactSheet(_ contact: any Contactable) {
        self.contactSheet = contact.sheet
    }

    func hideContactSheet() {
        self.contactSheet = nil
    }

    func dismiss(_ contact: any Contactable) {
        
    }
}
