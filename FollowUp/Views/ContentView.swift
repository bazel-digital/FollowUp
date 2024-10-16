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
    @State var settingsSheetShown: Bool = false
    @State private var rotation: Double = 0
    @State private var contactInteractorState: ContactInteractorState = .fetchingContacts
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    @EnvironmentObject var followUpManager: FollowUpManager
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
            TabView(selection: $selectedTab, content:  {
                
                // New Contacts View
                NavigationView {
                    NewContactsView(
                        store: followUpManager.store,
                        contactsInteractor: followUpManager.contactsInteractor
                    )
                    .navigationBarTitle("Contacts")
                    .toolbar(content: {
                        Button(action: {
                            self.settingsSheetShown = true
                        }, label: {
                            Image(icon: .settings)
                        })
                    })
                }
                .overlay(alignment: .topTrailing) {
                    if contactInteractorState == .fetchingContacts {
                        Image(icon: .arrowCirclePath)
                            .rotationEffect(.degrees(rotation)) // Apply rotation effect
                            .onAppear {
                                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                                    self.rotation = 360
                                }
                            }
                            .onDisappear {
                                self.rotation = 0
                            }
                            .padding(4)
                            .background(Material.ultraThin)
                            .cornerRadius(.greatestFiniteMagnitude)
                            .foregroundColor(.accent)
                            .padding(.top, 4)
                            .padding(.trailing, 50)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut, value: contactInteractorState)
                .tabItem {
                    Label("Contacts", systemImage: "person.crop.circle")
                }
                .tag(1)
                
                    
                // FollowUps View
                NavigationView {
                    FollowUpsView(store: followUpManager.store, contactsInteractor: followUpManager.contactsInteractor)
                        .navigationBarTitle("FollowUps")
                }
                .tabItem {
                    Label("FollowUp", systemImage: "arrow.up.message.fill")
                }
                .background(Color(.systemGroupedBackground))
                .tag(2)
            })
            .sheet(isPresented: $settingsSheetShown, content: {
                SettingsSheetView()
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
            .sheet(isPresented: $firstLaunch, onDismiss: {
                self.firstLaunch = false
            }, content: {
                WelcomeView()
            })
            .onReceive(followUpManager.contactsInteractor.contactSheetPublisher, perform: { contactSheet in
                self.contactSheet = contactSheet
            })
            .onReceive(followUpManager.contactsInteractor.statePublisher, perform: { contactInteractorState in
                self.contactInteractorState = contactInteractorState
            })
            .onChange(of: selectedTab, perform: { Log.info("Tab changed to \($0)") })
            .onChange(of: scenePhase, perform: { phase in
                switch phase {
                case .active:
                    followUpManager.contactsInteractor.fetchContacts()
                default: break
                }
            })
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FollowUpManager())
    }
}
