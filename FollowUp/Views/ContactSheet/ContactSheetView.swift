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
                    .textSelection(.enabled)
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
    
    private var closeButtonView: some View {
        HStack {
            Spacer()
            CloseButton(onClose: onClose)
                .padding([.top, .trailing])
        }
    }
    
    var modalContactSheetView: some View {
        NavigationView {
            
            ZStack(alignment: .top) {

                ScrollView(.vertical) {
                    VStack(spacing: verticalSpacing) {
                        Spacer()
                        VStack(spacing: Constant.ContactSheet.verticalSpacing) {
                            
                            contactBadgeAndNameView
                            
                            relativeTimeSinceMeetingView
                            
                            if let note = contact.note, !note.isEmpty {
                                ContactNoteView(note: note)
                            }
                            
                            contactDetailsView
                            
                        }.padding(.top, 50)
                        
                        
                        tagsView
                        Spacer()
                        startAConversationRowView
                        Spacer()
                        followUpDetailsView
                        Spacer(minLength: 120)
                        
                    }
                }

                // Overlay View
                VStack {
                    closeButtonView
                    Spacer()
                    ActionButtonGridView(contact: contact)
                        .padding()
                }
            }
        }
    }
    
    private var inlineContactSheetView: some View {
        VStack(spacing: verticalSpacing) {
            contactBadgeAndNameView
            
            relativeTimeSinceMeetingView
            
            contactDetailsView
                .padding(.top)
            ActionButtonGridView(contact: contact, background: .clear)
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
