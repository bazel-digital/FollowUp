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
    
    var iconForHeader: Constant.Icon {
        self.editingConversationStarter.kind.icon
    }
    
    private var modalHeader: some View {
        HStack(alignment: .center) {
            Spacer()
            Image(icon: iconForHeader)
                .resizable()
                .frame(width: Constant.Icon.mediumSize, height: Constant.Icon.mediumSize)
                .foregroundColor(.secondary)
                .animation(.default, value: self.editingConversationStarter.kind)
            Spacer()
        }.overlay(alignment: .trailing, content: {
            CloseButton(onClose: { dismiss() })
        })
    }
    
    var regularConversationStarterEditorView: some View {
        List {
            
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterMessageTitle.rawValue,
                    text: $editingConversationStarter.starter.template ?? "",
                    axis: .horizontal
                )
                .submitLabel(.done)
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
            }, header: {
                Text(.editConversationStarterName)
            }, footer: {
                Text(.editConversationStarterChooseNameDescription)
            })
        }
    }
    
    var intelligentConversationStarterEditorView: some View {
        List {
            
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterPromptTitle.rawValue,
                    text: $editingConversationStarter.starter.prompt ?? "",
                    axis: .horizontal
                )
                .submitLabel(.done)
            }, header: {
                Text(.editConversationStarterPromptTitle)
            }, footer: {
                Text(.editConversationStarterPromptDescription)
            })
            
            Section(content: {
                TextField(
                    LocalisedTextKey.editConversationStarterContextTitle.rawValue,
                    text: $editingConversationStarter.starter.context ?? "",
                    axis: .horizontal
                )
                .submitLabel(.done)
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
    
    @ViewBuilder
    private var conversationStarterEditorView: some View {
        switch self.editingConversationStarter.kind {
        case .intelligent: intelligentConversationStarterEditorView
        case .standard: regularConversationStarterEditorView
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
        .disabled(editingConversationStarter == savedConversationStarter)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var styledSaveButtonView: some View {
        switch self.editingConversationStarter.kind {
        case .standard: unstyledSaveButton.buttonStyle(.borderedProminent)
        case .intelligent: unstyledSaveButton.buttonStyle(GradientButtonStyle(colours: [.pink, .purple]))

        }
    }
    
    var body: some View {
        VStack {
            modalHeader
                .padding()
            
            Text("Edit Conversation Starter")
                .font(.title)
                .bold()
            
            Picker("Conversation Starter Kind", selection: $editingConversationStarter.kind, content: {
                ForEach(ConversationStarterKind.allCases, id: \.self) { kind in
                     Text("\(Image(systemName: kind.icon.rawValue)) \(kind.buttonTitle)")
//                        .tag(kind)
                }
            }).pickerStyle(.segmented)
            .padding()
            
            conversationStarterEditorView
            
            styledSaveButtonView
            
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
