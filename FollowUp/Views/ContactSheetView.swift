//
//  ContactSheetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactSheetView: View {
    
    // MARK: - Environment
    @EnvironmentObject var followUpManager: FollowUpManager

    // MARK: - Enums
    enum Kind {
        case modal
        case inline
    }

    // MARK: - Stored Properties
    var kind: Kind
    var sheet: ContactSheet
    var onClose: () -> Void
    var verticalSpacing: CGFloat = Constant.ContactSheet.verticalSpacing
    
    // MARK: - Computed Properties
    var relativeTimeSinceMeetingString: String {
        Constant.relativeDateTimeFormatter.localizedString(for: contact.createDate, relativeTo: .now)
    }

    private var relativeTimeSinceFollowingUp: String {
        guard let lastFollowedUpDate = contact.lastFollowedUp else { return "Never" }
        return Constant.relativeDateTimeFormatter
            .localizedString(
                for: lastFollowedUpDate,
                   relativeTo: .now
            )
    }
    
    private var relativeTimeSinceMeetingView: some View {
        (Text(Image(icon: .clock)) +
         Text(" Met ") +
         Text(relativeTimeSinceMeetingString))
            .fontWeight(.medium)
    }

    private var contact: Contact {
        followUpManager.store.contact(forID: sheet.contactID)?.concrete ?? .unknown
    }
    
    // MARK: - Views
    @ViewBuilder
    private var contactBadgeAndNameView: some View {
        BadgeView(
            name: contact.name,
            image: contact.thumbnailImage,
            size: .large
        )
        Text(contact.name)
            .font(.largeTitle)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var contactDetailsView: some View {
        VStack {
            if let phoneNumber = contact.phoneNumber {
                Text(phoneNumber.value)
                    .font(.title2)
                    .foregroundColor(.secondary)
                HStack {
                    CircularButton(icon: .phone, action: .call(number: phoneNumber))
                    CircularButton(icon: .sms, action: .sms(number: phoneNumber))
                    CircularButton(icon: .whatsApp, action: .whatsApp(number: phoneNumber, prefilledText: nil))
                }
            }
        }
    }

    @ViewBuilder
    private var followUpDetailsView: some View {
        VStack {
            Text("Last followed up: \(relativeTimeSinceFollowingUp)")
            Text("Total follow ups: \(contact.followUps)")
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    // MARK: - Buttons
    private var highlightButton: some View {
        Button(action: {
            followUpManager
                .contactsInteractor
                .highlight(contact)
        }, label: {
            VStack {
                Image(icon: .star)
                Text("Highlight")
            }
        })
        .accentColor(.yellow)
    }

    private var unhighlightButton: some View {
        Button(action: {
            followUpManager
                .contactsInteractor
                .unhighlight(contact)
        }, label: {
            VStack {
                Image(icon: .slashedStar)
                Text("Unhighlight")
            }
        })
        .accentColor(.orange)
    }

    private var followedUpButton: some View {
        Button(action: {
            followUpManager
                .contactsInteractor
                .markAsFollowedUp(contact)
        }, label: {
            VStack {
                Image(icon: .thumbsUp)
                Text("I followed up")
            }
        })
        .accentColor(.green)
        .disabled(contact.hasBeenFollowedUpToday)
    }

    private var addToFollowUpsButton: some View {
        Button(action: {
            followUpManager
                .contactsInteractor
                .addToFollowUps(contact)
        }, label: {
            VStack {
                Image(icon: .plus)
                Text("Add to follow ups")
            }
        })
    }

    private var removeFromFollowUpsButton: some View {
        Button(action: {
            followUpManager
                .contactsInteractor
                .removeFromFollowUps(contact)
        }, label: {
            VStack {
                Image(icon: .minus)
                Text("Remove from follow ups")
            }
        })
    }

    private var actionButtonGrid: some View {
        LazyVGrid(columns: [
            .init(), .init(), .init()
        ], alignment: .center, content: {
  
            
            if !contact.highlighted { highlightButton } else { unhighlightButton }
            if !contact.containedInFollowUps { addToFollowUpsButton } else { removeFromFollowUpsButton }
            followedUpButton
            
        })
    }

    // TODO: Refactor this out into a separate view.
    @ViewBuilder
    private var startAConversationRowView: some View {
        if let phoneNumber = contact.phoneNumber {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Constant.conversationStarters, id: \.self) { conversationStarter in
                        ConversationActionButtonView(
                            type: .whatsApp,
                            contact: contact,
                            prefilledText: conversationStarter
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    var modalContactSheetView: some View {
        VStack(spacing: verticalSpacing) {

            
                HStack {
                    Spacer()
                    CloseButton(onClose: onClose)
                        .padding([.top, .trailing])
                }
                Spacer()

            VStack {

                contactBadgeAndNameView
                
                if let note = contact.note, !note.isEmpty {
                    Text(note)
                        .italic()
                }
                relativeTimeSinceMeetingView

                contactDetailsView
                    .padding(.top)
            }
            
            Spacer()
            startAConversationRowView
            Spacer()
            followUpDetailsView
            Spacer()
            actionButtonGrid
                .padding()
        }
    }

    private var inlineContactSheetView: some View {
        VStack(spacing: verticalSpacing) {
            contactBadgeAndNameView
            
            if let note = contact.note, !note.isEmpty {
                Text(note)
                    .italic()
            }
            
            relativeTimeSinceMeetingView
            
            contactDetailsView
                .padding(.top)
            actionButtonGrid
                .padding([.top, .horizontal])
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constant.cornerRadius)
    }

    var body: some View {
        switch kind {
        case .modal: modalContactSheetView
        case .inline: inlineContactSheetView
        }
    }
    
}

struct ContactModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactSheetView(kind: .modal, sheet: MockedContact(id: "1").sheet, onClose: { })
            ContactSheetView(kind: .inline, sheet: MockedContact(id: "0").sheet, onClose: { })
            ContactSheetView(kind: .modal, sheet: MockedContact(id: "0").sheet, onClose: { })
                .preferredColorScheme(.dark)
        }
        .environmentObject(FollowUpManager(store: .mocked(withNumberOfContacts: 5)))
    }
}
