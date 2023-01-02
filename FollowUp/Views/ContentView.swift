//
//  ContentView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Contacts
import SwiftUI

struct ContentView: View {

    @State var selectedTab: Int = 0
    @State var contactSheet: ContactSheet?
    @EnvironmentObject var followUpManager: FollowUpManager

    var body: some View {
            TabView(selection: $selectedTab, content:  {
                NavigationView {
                    NewContactsView(store: followUpManager.store, contactsInteractor: followUpManager.contactsInteractor)
                        .navigationBarTitle("Contacts")
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
                    
                NavigationView {
                    FollowUpsView(store: followUpManager.store, contactsInteractor: followUpManager.contactsInteractor)
                    .navigationBarTitle("FollowUps")
                }
                .tabItem {
                    Label("FollowUp", systemImage: "repeat")
                }
                .background(Color(.systemGroupedBackground))
            })
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
            .onReceive(followUpManager.contactsInteractor.contactSheetPublisher, perform: { contactSheet in
                self.contactSheet = contactSheet
            })
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FollowUpManager())
    }
}
