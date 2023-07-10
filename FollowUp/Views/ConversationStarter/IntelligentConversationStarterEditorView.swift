//
//  IntelligentConversationStarterEditorView.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/07/2023.
//

import SwiftUI

struct IntelligentConversationStarterEditorView: View {
    
    // MARK: - Stored Properties
    @FocusState private var textFieldIsFocused: Bool
    @Binding var editingConversationStarter: ConversationStarterTemplate
    
    // MARK: - Views
    private var intelligentEditorTextFieldToolbar: some View {
        HStack {
            Spacer()
            Button("Done", action: self.hideTextField)
        }
    }

    var body: some View {
        List {
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterPromptTitle.rawValue,
                    text: $editingConversationStarter.starter.prompt ?? "",
                    axis: .vertical
                )
                .focused($textFieldIsFocused)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        intelligentEditorTextFieldToolbar
                    }
                }
            }, header: {
                Text(.editConversationStarterPromptTitle)
            }, footer: {
                Text(.editConversationStarterPromptDescription)
            })
            
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterContextTitle.rawValue,
                    text: $editingConversationStarter.starter.context ?? "",
                    axis: .vertical
                )
                .focused($textFieldIsFocused)
            }, header: {
                Text(.editConversationStarterContextTitle)
            }, footer: {
                Text(.editConversationStarterContextDescription)
            })
            
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
        }
    }
    
    // MARK: - Methods
    private func hideTextField() {
        self.textFieldIsFocused = false
    }

}

struct IntelligentConversationStarterEditorView_Previews: PreviewProvider {
    static var previews: some View {
        IntelligentConversationStarterEditorView(editingConversationStarter: .constant(.arrangeForCoffee))
    }
}
