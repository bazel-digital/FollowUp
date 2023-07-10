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
    @FocusState private var textFieldIsFocused: Bool
    
    var iconForHeader: Constant.Icon {
        self.editingConversationStarter.kind.icon
    }
    
    private var saveButtonDisabled: Bool {
        editingConversationStarter == savedConversationStarter
    }
    
    private var modalHeader: some View {
        HStack(alignment: .center) {
            Spacer()
            Image(icon: iconForHeader)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constant.Icon.mediumSize, height: Constant.Icon.mediumSize)
                .foregroundColor(.secondary)
                .animation(.default, value: self.editingConversationStarter.kind)
            Spacer()
        }.overlay(alignment: .trailing, content: {
            CloseButton(onClose: { dismiss() })
        })
    }
    
    @ViewBuilder
    private var conversationStarterEditorView: some View {
        switch self.editingConversationStarter.kind {
        case .intelligent:
            IntelligentConversationStarterEditorView(editingConversationStarter: $editingConversationStarter)
                
        case .standard:
            RegularConversationStarterEditorView(editingConversationStarter: $editingConversationStarter)
        }
    }
    
    private var unstyledSaveButton: some View {
        Button(action: {
            self.save(editingConversationStarter)
        }, label: {
            Text(.editConversationStarterSaveButtonTitle)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        })
        .disabled(saveButtonDisabled)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var styledSaveButtonView: some View {
        switch self.editingConversationStarter.kind {
        case .standard: unstyledSaveButton.buttonStyle(.borderedProminent)
        case .intelligent: unstyledSaveButton.buttonStyle(
            GradientButtonStyle(
                colours: [.pink, .purple],
                disabled: saveButtonDisabled
            )
        )

        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                modalHeader
                    .padding()
                
                Text("Edit Conversation Starter")
                    .font(.title)
                    .bold()
                
                Picker("Conversation Starter Kind", selection: $editingConversationStarter.kind, content: {
                    ForEach(ConversationStarterKind.allCases, id: \.self) { kind in
                         Text("\(Image(systemName: kind.icon.rawValue)) \(kind.buttonTitle)")
                    }
                }).pickerStyle(.segmented)
                .padding()
                
                conversationStarterEditorView
                
                styledSaveButtonView
                
            }
            .background(Color(.systemGroupedBackground))
        }
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
//    @State static var template: ConversationStarterTemplate = .init(label: "Event Invite", template: "Hey \(Constant.ConversationStarter.Token.name), want to come to my event?", platform: .whatsApp)
    static var previews: some View {
        EditConversationStarterView(conversationStarter: .init(label: "Event Invite", template: "Hey \(Constant.ConversationStarter.Token.name), want to come to my event?", platform: .whatsApp))
    }
}
