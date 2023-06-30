//
//  ConversationActionButtonView.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import SwiftUI

struct ConversationActionButtonView: View {
    
    // MARK: - Stored Properties
    var template: ConversationStarterTemplate
    var contact: any Contactable
    @State var isLoading: Bool = false
    @State var intelligentConversationStarterError: Networking.NetworkingError?

    var maxWidth: CGFloat = Constant.ConversationActionButton.maxWidth
    
    // MARK: - Computed Properties
    var labelText: String {
        guard let label = template.label, !label.isEmpty else {
            return template.title
        }
        return label
    }
    
    private var buttonView: some View {
        Button(action: {
            do {
                let action = try template.buttonAction(contact: contact)
                self.isLoading = true
                action?.closure(completion: { (result: Result<URL, Error>?) in
                    self.isLoading = false
                    
                    switch result {
                    case let .failure(error):
                        self.intelligentConversationStarterError = error as? Networking.NetworkingError
                    default: ()
                    }
                })
            } catch {
                Log.error("Could not perform button action: \(error.localizedDescription)")
            }
        }, label: {
            Label(
                title: {
                    Text(labelText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: maxWidth)
                },
                icon: {
                    if isLoading {
                        CircularLoadingSpinner(
                            lineWidth: 3,
                            colour: .white
                        )
                        .frame(width: 25, height: 25)
                    } else {
                        Image(icon: template.platform.icon)
                            .renderingMode(.template)
                    }
                }
            )
        }).alert(item: $intelligentConversationStarterError) { error in
            Alert(
                title: Text("Unable To Generate Message"),
                message: Text(error.description),
                dismissButton: .cancel()
            )
        }
    }
    
    private var standardConversationStarterButton: some View {
        buttonView
            .foregroundColor(.secondary)
            .fontWeight(.semibold)
            .padding()
            .background(Color(.tertiarySystemFill))
            .cornerRadius(Constant.cornerRadius)
    }
    
    private var intelligentConversationStarterButton: some View {
        buttonView
            .foregroundColor(.secondary)
            .fontWeight(.semibold)
            .buttonStyle(
                GradientButtonStyle(
                    colours: [.pink, .purple],
                    cornerRadius: Constant.cornerRadius
                )
            )
            .cornerRadius(Constant.cornerRadius)
    }
    
    var body: some View {
        switch self.template.kind {
        case .intelligent: intelligentConversationStarterButton
        case .standard: standardConversationStarterButton
        }
    }
}

struct ConversationActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                ConversationActionButtonView(template: .init(template: "Hey <NAME>!", platform: .whatsApp), contact: Contact.mocked)
                ConversationActionButtonView(template: .init(template: "Hey <NAME>!", platform: .whatsApp), contact: Contact.mocked)
                ConversationActionButtonView(template: .init(prompt: "Something", context: "Else", platform: .whatsApp), contact: Contact.mocked, isLoading: true)
            }
            ConversationActionButtonView(template: .init(prompt: "Something", context: "Else", platform: .whatsApp), contact: Contact.mocked, isLoading: true)
        }
        .previewLayout(.sizeThatFits)

    }
}
