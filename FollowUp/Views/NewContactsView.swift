//
//  NewContactsView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import RealmSwift
import SwiftUI

struct NewContactsView: View {

    @State var contacts: [any Contactable] = []
    @ObservedObject var store: FollowUpStore
    
    var contactsInteractor: ContactsInteracting

    // MARK: - Computed Properties

    private var sortedContacts: [any Contactable] {
        store
            .contacts
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

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        ContactListView(contactSetions: contactSections)
            .animation(.easeInOut, value: contacts.count)
            .animation(.easeInOut, value: newContactsCount)
    }

}

struct NewContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactsView(store: FollowUpStore(), contactsInteractor: ContactsInteractor(realm: nil))
//            .environmentObject(FollowUpManager(store: .mocked(withNumberOfContacts: 4)))
    }
}
