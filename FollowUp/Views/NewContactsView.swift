//
//  NewContactsView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import SwiftUI

struct NewContactsView: View {

    @State var contacts: [Contactable] = []
    @State private var contactSheet: ContactSheet?

    @EnvironmentObject var followUpManager: FollowUpManager

    // MARK: - Computed Properties

    private var sortedContacts: [Contactable] {
        followUpManager
                    .store
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

    // MARK: - Views

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(contactSections) { section in
                    ContactListView(
                        section: section,
                        layoutDirection: section.grouping == .new ? .horizontal : .vertical
                    )
                }
                .padding(.vertical)
            }
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
        .task {
            await self
                .followUpManager
                .fetchContacts()
        }
        .sheet(item: $contactSheet, onDismiss: {
            followUpManager.contactsInteractor.hideContactSheet()
        }, content: {
            ContactModalView(sheet: $0, onClose: {
                followUpManager.contactsInteractor.hideContactSheet()
            })
        })
        .onReceive(followUpManager.contactsInteractor.contactSheetPublisher, perform: {
            self.contactSheet = $0
        })
    }

}

struct NewContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactsView(contacts: [])
            .background(Color(.systemGroupedBackground))
            .environmentObject(ContactsInteractor())
    }
}
