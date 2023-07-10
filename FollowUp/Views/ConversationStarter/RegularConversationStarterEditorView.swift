//
//  RegularConversationStarterEditorView.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/07/2023.
//

import SwiftUI

struct RegularConversationStarterEditorView: View {
    
    // MARK: - Stored Properties
    @FocusState private var textFieldIsFocused: Bool
    @Binding var editingConversationStarter: ConversationStarterTemplate
    
    // MARK: - Views
    private var standardEditorTextFieldToolbar: some View {
        HStack {
            Text("Special Tokens")
                .font(.caption.bold())
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Constant.ConversationStarter.Token.allCases, id: \.self) { token in
                        ChipView(title: token.title, action: {
                            self.insertTextFieldToken(token)
                        })
                    }
                }
            }
            Spacer()
            Button("Done", action: self.hideTextField)
        }
    }

    var body: some View {
        List {
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterMessageTitle.rawValue,
                    text: $editingConversationStarter.starter.template ?? "",
                    axis: .vertical
                )
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        standardEditorTextFieldToolbar
                    }
                }
                .submitLabel(.return)
                .focused($textFieldIsFocused)
            }, header: {
                Text(.editConversationStarterMessageTitle)
            }, footer: {
                Text(.editConversationStarterMessageDescription)
            })
            
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterName.rawValue,
                    text: $editingConversationStarter.label ?? ""
                )
                .submitLabel(.done)
                .focused($textFieldIsFocused)

            }, header: {
                Text(.editConversationStarterName)
            }, footer: {
                Text(.editConversationStarterChooseNameDescription)
            })
        }
    }
    
    // MARK: - Methods
    private func insertTextFieldToken(_ token: Constant.ConversationStarter.Token) {
        self.editingConversationStarter.starter.template = (self.editingConversationStarter.starter.template ?? "") + token.rawValue
    }
    
    private func hideTextField() {
        self.textFieldIsFocused = false
    }
}

struct RegularConversationStarterEditorView_Previews: PreviewProvider {
    static var previews: some View {
        RegularConversationStarterEditorView(editingConversationStarter: .constant(.arrangeForCoffee))
    }
}
