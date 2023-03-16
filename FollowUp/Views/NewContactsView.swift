//
//  NewContactsView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import RealmSwift
import SwiftUI

struct NewContactsView: View {

    @ObservedObject var store: FollowUpStore
    @State var contactInteractorState: ContactInteractorState = .fetchingContacts
    @State var searchQuery: String = ""
    var contactsInteractor: ContactsInteracting

    // MARK: - Computed Properties

    private var sortedContacts: [any Contactable] {
        store
            .contacts
            .filter { contact in
                guard !searchQuery.isEmpty else { return true }
                return contact.name.fuzzyMatch(searchQuery)
            }
            .sorted(by: \.createDate)
            .reversed()
    }

    private var contactSections: [ContactSection] {
        sortedContacts
            .grouped(by: \.grouping)
            .map { grouping, contacts in
                .init(
                    contacts: contacts
                        .sorted(by: \.createDate)
                        .reversed(),
                    grouping: grouping
                )
            }
            .sorted(by: \.grouping)
    }

    private var newContactsCount: Int {
        contactSections.filter { $0.grouping == .new }.count
    }
    
    // MARK: - Views
    
    
    private var contactsListView: some View {
        ContactListView(contactSetions: contactSections)
            .animation(.easeInOut, value: store.contacts.count)
            .animation(.easeInOut, value: newContactsCount)
            .searchable(text: $searchQuery, placement: .automatic, prompt: "Search")
    }
    
    @ViewBuilder
    var content: some View {
        switch (contactInteractorState, store.contacts.isEmpty) {
        case (.fetchingContacts, true): HeroMessageView(
            header: .fetchingContactsHeader,
            icon: .arrowCirclePath
        )
        case (.authorizationDenied, _): HeroMessageView(
            header: .authorisationDeniedHeader,
            subheader: .authorisationDeniedSubheader,
            icon: .lockWithExclamationMark
        )
        case (.requestingAuthorization, _): HeroMessageView(
            header: .awaitingAuthorisationHeader,
            subheader: .awaitingAuthorisationSubheader,
            icon: .lock
        )
        default: contactsListView
        }
    }

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        content
            .onReceive(contactsInteractor.statePublisher, perform: { self.contactInteractorState = $0 })
    }

}

struct NewContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactsView(store: FollowUpStore(), contactsInteractor: ContactsInteractor(realm: nil))
            .environmentObject(FollowUpManager(store: FollowUpStore()))
    }
}
