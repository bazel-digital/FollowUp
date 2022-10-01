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
            TabView(selection: $selectedTab, content:  {
                NavigationView {
                    NewContactsView()
                        .navigationBarTitle("Contacts")
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
                    
                NavigationView {
                    FollowUpsView()
                    .navigationBarTitle("FollowUps")
                }
                .tabItem {
                    Label("FollowUp", systemImage: "repeat")
                }
                .background(Color(.systemGroupedBackground))
            })
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FollowUpManager())
    }
}
