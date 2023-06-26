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
    @EnvironmentObject var settings: FollowUpSettings
    @State var contactInteractorState: ContactInteractorState = .fetchingContacts
    @State var searchQuery: String = ""
    @State var availableTagSearchTokens: [Tag] = []
    @State var selectedTagSearchTokens: [Tag] = []
    var contactsInteractor: ContactsInteracting
    
    @Environment(\.isSearching) var isSearching
    
    // MARK: - Computed Properties
    
    private var newContactsCount: Int {
        store.contactSections.filter { $0.grouping == .new }.count
    }
    
    private var suggestedTagSearchTokens: [Tag] {
        availableTagSearchTokens.filter {
            $0.title.fuzzyMatch(searchQuery) && !selectedTagSearchTokens.contains($0)
        }
    }
    
    // MARK: - Views
    
    private var contactsListView: some View {
        ContactListView(
            contactSetions: store.contactSections,
            suggestedTagSearchTokens: suggestedTagSearchTokens, selectedTagSearchTokens: $selectedTagSearchTokens
        )
        .animation(.easeInOut, value: newContactsCount)
        .searchable(
            text: $searchQuery,
            tokens: $selectedTagSearchTokens,
            placement: .automatic,
            prompt: "Search",
            token: { token in TagChipView(tag: token) }
        )
        .onChange(of: searchQuery, perform: self.store.set(contactSearchQuery:))
        .onChange(of: selectedTagSearchTokens, perform: self.store.set(selectedTagSearchTokens:))
        .onReceive(store.$allTags, perform: { self.availableTagSearchTokens = $0 })
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
