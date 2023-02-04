//
//  EditConversationStarterView.swift
//  FollowUp
//
//  Created by Aaron Baw on 26/01/2023.
//

import SwiftUI

struct EditConversationStarterView: View {
    
    @EnvironmentObject var store: FollowUpStore
    @Environment(\.dismiss) var dismiss
    
    @State var editingConversationStarter: ConversationStarterTemplate
    @State var savedConversationStarter: ConversationStarterTemplate
    
    private var closeButton: some View {
        HStack(alignment: .center) {
            Spacer()
            CloseButton(onClose: { dismiss() })
        }
    }

    var body: some View {
        VStack {
            closeButton
                .padding()
            Text("Edit Conversation Starter")
                .font(.title)
                .bold()
            List {
                Section(content: {
                    TextField(
                        LocalisedTextKey.editConversationStarterName.rawValue,
                        text: $editingConversationStarter.label ?? ""
                    )
                    .submitLabel(.done)
                }, header: {
                    Text(.editConversationStarterName)
                }, footer: {
                    Text(.editConversationStarterChooseNameDescription)
                })
                
                Section(content: {
                    TextField(
                        LocalisedTextKey.editConversationStarterMessageTitle.rawValue,
                        text: $editingConversationStarter.template,
                        axis: .horizontal
                    )
                    .submitLabel(.done)
                }, header: {
                    Text(.editConversationStarterMessageTitle)
                }, footer: {
                    Text(.editConversationStarterMessageDescription)
                })
            }
            Button(action: {
                self.save(editingConversationStarter)
            }, label: {
                Text(.editConversationStarterSaveButtonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            })
            .disabled(editingConversationStarter == savedConversationStarter)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Custom Initialiser
    init(conversationStarter: ConversationStarterTemplate) {
        self._editingConversationStarter = .init(initialValue: conversationStarter)
        self._savedConversationStarter = .init(initialValue: conversationStarter)
    }
    
    // MARK: - Methods
    private func save(_ conversationStarter: ConversationStarterTemplate) {
        self.store.settings.update(conversationStarter: editingConversationStarter)
        self.savedConversationStarter = editingConversationStarter
    }
    
}

struct EditConversationStarterView_Previews: PreviewProvider {
//    @State static var template: ConversationStarterTemplate = .init(label: "Event Invite", template: "Hey <NAME>, want to come to my event?", platform: .whatsApp)
    static var previews: some View {
        EditConversationStarterView(conversationStarter: .init(label: "Event Invite", template: "Hey <NAME>, want to come to my event?", platform: .whatsApp))
    }
}
