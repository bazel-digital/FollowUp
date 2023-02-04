//
//  SettingsSheetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import SwiftUI

struct SettingsSheetView: View {

    @State var dailyFollowUpGoal: Int = 0
    @EnvironmentObject var settings: FollowUpSettings
    @Environment(\.dismiss) private var dismiss
    @FocusState var dailyGoalInputActive: Bool
    @Environment(\.editMode) var isEditing
    
    @State var currentlyEditingConversationStarter: ConversationStarterTemplate? = nil
    
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
    
    private var conversationStartersSectionView: some View {
        Section(content: {
            List {
                ForEach(settings.conversationStarters, id: \.id, content: { conversationStarter in
                    Button(action: {
                        self.openEditConversationStarterModal(forConversationStarter: conversationStarter)
                    }, label: {
                        HStack {
                            Text(conversationStarter.title)
                                .lineLimit(1)
                            Spacer()
                            Image(icon: .chevronRight)
                        }.foregroundColor(.primary)
                        
                    })
                })
                .onDelete(perform: self.settings.removeConversationStareters(atOffsets:))
                .onMove(perform: self.settings.moveConversationStarters(fromOffsets:toOffset:))
                
//                if isEditing?.wrappedValue == .active {
//                    Button(action: {
//                        self.settings.addNewConversationStarter()
//                    }, label: {
//                        Text("New Conversation Starter")
//                            .multilineTextAlignment(.center)
//                            .frame(maxWidth: .infinity)
//                    })
//                    .listRowInsets(nil)
//                    .frame(maxWidth: .infinity)
//                    .animation(.default, value: isEditing?.wrappedValue)
//                }
                
            }
        }, header: {
            HStack {
                Label("Conversation Starters", systemImage: Constant.Icon.chatBubbles.rawValue)
                Spacer()
                EditButton()
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
            }
        }, footer: {
            Button(action: {
                self.settings.addNewConversationStarter()
            }, label: {
                Text("New Conversation Starter")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            })
            .listRowInsets(nil)
            .frame(maxWidth: .infinity)
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
                conversationStartersSectionView
            }
        }.navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
        .sheet(item: self.$currentlyEditingConversationStarter, content: { conversationStarter in
            EditConversationStarterView(conversationStarter: conversationStarter)
        })
    }
    
    // MARK: - Methods
    private func openEditConversationStarterModal(forConversationStarter conversationStarter: ConversationStarterTemplate) {
        self.currentlyEditingConversationStarter = conversationStarter
    }
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
