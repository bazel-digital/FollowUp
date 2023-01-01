//
//  ConversationActionButtonView.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import SwiftUI

struct ConversationActionButtonView: View {
    
    // MARK: - Enums
    enum ActionType {
        case whatsApp

        var icon: Constant.Icon {
            switch self {
            case .whatsApp: return .whatsApp
            }
        }
    }

    var type: ActionType
    var contact: any Contactable
    var prefilledText: String

    var maxWidth: CGFloat = Constant.ConversationActionButton.maxWidth
    
    var body: some View {
        Button(action: {
            let action = buttonAction(forType: type, prefilledText: prefilledText, contact: contact)
            action?.closure()
        }, label: {
            Label(
                title: {
                    Text(formattedText(forPrefilledText: prefilledText, withContact: contact))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: maxWidth)
                    
                },
                icon: { Image(icon: type.icon).renderingMode(.template) }
            )
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
                .padding()
                .background(Color(.tertiarySystemFill))
                .cornerRadius(Constant.cornerRadius)
        })
    }

    // MARK: - Methods
    func buttonAction(
        forType type: ActionType,
        prefilledText: String,
        contact: any Contactable
    ) -> ButtonAction? {
        switch type {
        case .whatsApp:
            guard let number = contact.phoneNumber else { return nil }
            let replacedString = formattedText(forPrefilledText: prefilledText, withContact: contact)
            return .whatsApp(number: number, prefilledText: replacedString)
        }
    }

    private func formattedText(
        forPrefilledText prefilledText: String,
        withContact contact: any Contactable
    ) -> String {
        prefilledText.replacingOccurrences(of: "<NAME>", with: contact.firstName)
    }
}

struct ConversationActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConversationActionButtonView(type: .whatsApp, contact: .mocked, prefilledText: "Hey <NAME>!")
        }
        .previewLayout(.sizeThatFits)
    }
}
