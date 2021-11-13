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

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab,
                    content:  {
                        NewContactsView()
                        .navigationBarTitle("New Contacts")
                        .tabItem {
                            Label("New", systemImage: "person.crop.circle")
                        }.tag(1)
                        
                        Text("Tab Content 2")
                        .navigationBarTitle("FollowUp")
                        .tabItem {
                            Label("FollowUp", systemImage: "repeat")
                        }.tag(2)
                })
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContactsInteractor())
    }
}
