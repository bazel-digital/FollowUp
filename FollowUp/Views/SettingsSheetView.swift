//
//  SettingsSheetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import SwiftUI

struct SettingsSheetView: View {

    @State var dailyFollowUpGoal: Int = 0
    @State var contactListGrouping: FollowUpSettings.ContactListGrouping = .dayMonthYear
    @State var followUpRemindersActive: Bool = false
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    @AppStorage("v.7FirstLaunch") var newVersionLaunch: Bool = true
    @EnvironmentObject var settings: FollowUpSettings
    @EnvironmentObject var followUpManager: FollowUpManager
    @Environment(\.dismiss) private var dismiss
    @FocusState var dailyGoalInputActive: Bool
    @Environment(\.editMode) var isEditing
        
    #if DEBUG
    @State var openAIKey: String = ""
    #endif
    
    private var closeButton: some View {
        HStack(alignment: .center) {
            Spacer()
            CloseButton(onClose: { dismiss() })
        }
    }
    
    private var dailyGoalSectionView: some View {
        Section(content: {
            HStack {
                Label(title: {
                    Text("Daily Goal")
                }, icon: {
                        Image(icon: .thumbsUp)
                    .foregroundColor(.secondary) }
                )
                TextField("FollowUps", value: $dailyFollowUpGoal, formatter: NumberFormatter())
                    .focused($dailyGoalInputActive)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button("Done") {
                                dailyGoalInputActive = false
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                        if let textField = obj.object as? UITextField {
                            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                        }
                    }
                    .onChange(of: dailyFollowUpGoal, perform: self.settings.set(dailyFollowUpGoal:))
                    .onAppear {
                        self.dailyFollowUpGoal = self.settings.dailyFollowUpGoal ?? self.dailyFollowUpGoal
                    }
            }
        })
    }
        
    private var groupingSelectionSectionView: some View {
        Section(content: {
            Picker(selection: $contactListGrouping, content: {
                ForEach(FollowUpSettings.ContactListGrouping.allCases, id: \.self, content: { grouping in
                    Text(grouping.title)
                })
            }, label: {
                Text("Grouping")
            })
        }).onAppear {
            self.contactListGrouping = self.settings.contactListGrouping
        }.onChange(of: self.contactListGrouping, perform:self.settings.set(contactListGrouping:))
    }
    
    #if DEBUG
    private var openAIKeySectionView: some View {
        Section(content: {
            TextField("OpenAI Key", text: $openAIKey)
        }, header: {
            Text("OpenAI Key")
        }, footer: {
            Text("Required for Intelligent conversation starters. Register yours at https://platform.openai.com/account/api-keys/")
        }).onAppear {
            self.openAIKey = self.settings.openAIKey
        }.onChange(of: self.openAIKey, perform: self.settings.set(openAIKey:))
        .submitLabel(.done)
    }
    #endif
    
    #if DEBUG
    private var resetOnboardingView: some View {
        Section(content: {
            Button(action: {
                self.firstLaunch = true
            }, label: {
                Text("Reset First Launch")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .greatestFiniteMagnitude)
            })
            
            Button(action: {
                self.newVersionLaunch = true
            }, label: {
                Text("Reset New Version")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .greatestFiniteMagnitude)
            })
        }, header: {
            Text("Debugging")
        }, footer: {
            Text("Pressing these forces the app to show the onboarding / new features screen on next launch.")
        })
    }
    #endif
    
    private var followUpRemindersToggleView: some View {
        Section(content: {
            Toggle(isOn: $followUpRemindersActive, label: { Text(.followUpReminderToggleText) })
        }, footer: {
            Text(.followUpReminderFooterText)
        })
        .onAppear {
            self.followUpRemindersActive = self.settings.followUpRemindersActive
        }
        .onChange(of: self.followUpRemindersActive, perform: { newValue in
            // If the user has not granted notification permissions, do that now.
            self.followUpManager.configureNotifications()
            self.settings.set(followUpRemindersActive: newValue)
        })
    }
    
    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        
        VStack {
            closeButton
                .padding([.leading, .trailing, .top])
            
            Text("Settings")
                .font(.title)
                .bold()
            
            Form {
                dailyGoalSectionView
                groupingSelectionSectionView
                followUpRemindersToggleView
                
                #if DEBUG
                openAIKeySectionView
                resetOnboardingView
                #endif
            }
            .background(Color(.systemGroupedBackground))
        }.background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Methods

}

struct SettingsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sample")
            .sheet(isPresented: .constant(true), content: {
                SettingsSheetView()
            })
            .environmentObject(FollowUpStore())
            .environmentObject(FollowUpSettings())
    }
}
