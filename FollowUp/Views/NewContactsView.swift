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
    @State private var contactSheet: ContactSheet?

    @EnvironmentObject var followUpManager: FollowUpManager
    @ObservedResults(Contact.self, sortDescriptor: .init(keyPath: "createDate", ascending: true)) var sortedContacts

    // MARK: - Computed Properties

//    private var sortedContacts: [Contactable] {
//        followUpManager
//                    .store
//                    .contacts
//                    .sorted(by: \.createDate)
//                    .reversed()
//    }

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
        ContactListView(contactSetions: contactSections)
            .task {
                await self
                    .followUpManager
                    .fetchContacts()
            }
            .sheet(item: $contactSheet, onDismiss: {
                followUpManager.contactsInteractor.hideContactSheet()
            }, content: {
                ContactSheetView(
                    kind: .modal,
                    sheet: $0,
                    onClose: {
                        followUpManager.contactsInteractor.hideContactSheet()
                    })
            })
            .onReceive(followUpManager.contactsInteractor.contactSheetPublisher, perform: {
                self.contactSheet = $0
            })
            .animation(.easeInOut, value: contacts.count)
            .animation(.easeInOut, value: newContactsCount)
    }

}

struct NewContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactsView()
            .environmentObject(FollowUpManager(store: .mocked(withNumberOfContacts: 4)))
    }
}
