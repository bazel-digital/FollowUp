//
//  ContactSheetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactSheetView: View {
    
    // MARK: - Environment
    @EnvironmentObject var store: FollowUpStore
    @EnvironmentObject var followUpManager: FollowUpManager
    var contactsInteractor: ContactsInteracting { followUpManager.contactsInteractor }

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

    private var contact: any Contactable {
        store.contact(forID: sheet.contactID) ?? Contact.unknown
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
                    CircularButton(icon: .whatsApp, action: .whatsApp(number: phoneNumber, generateText: { completion in completion(.success("")) }))
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
            contactsInteractor
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
            contactsInteractor
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
            contactsInteractor
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
            contactsInteractor
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
            contactsInteractor
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
        if (contact.phoneNumber) != nil {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(store.settings.conversationStarters) { conversationStarter in
                        ConversationActionButtonView(template: conversationStarter, contact: contact)
                    }
                }
                .padding()
            }
        }
    }
    
    private var tagsView: some View {
        TagsCarouselView(contact: contact)
    }
    
    var modalContactSheetView: some View {
        NavigationView {
            VStack(spacing: verticalSpacing) {
                    HStack {
                        Spacer()
                        CloseButton(onClose: onClose)
                            .padding([.top, .trailing])
                    }
                    Spacer()

            VStack(spacing: Constant.ContactSheet.verticalSpacing) {

                    contactBadgeAndNameView
                    
                    if let note = contact.note, !note.isEmpty {
                        ContactNoteView(note: note)
                    }

                    relativeTimeSinceMeetingView

                    contactDetailsView
                        .padding(.top)
                }
                
                
                tagsView
                Spacer()
                startAConversationRowView
                Spacer()
                followUpDetailsView
                Spacer()
                actionButtonGrid
                    .padding()
            }
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
            ContactSheetView(kind: .modal, sheet: MockedContact(
                id: "1",
                note: "Met on the underground at Euston Station. Works at a local hedgefund and is into cryptocurrency. Open to coming out, but is quite busy."
            ).sheet, onClose: { })

            ContactSheetView(kind: .inline, sheet: MockedContact(id: "0").sheet, onClose: { })

            ContactSheetView(kind: .modal, sheet: MockedContact(id: "0").sheet, onClose: { })
                .preferredColorScheme(.dark)
        }
        .environmentObject(FollowUpManager())
        .environmentObject(FollowUpStore())
    }
}
