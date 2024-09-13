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
    
    // MARK: - State
    @State private var nativeContactSheetID: String?
    
    // MARK: - Computed Properties
    private var relativeTimeSinceFollowingUp: String {
        guard let lastFollowedUpDate = contact.lastFollowedUp else { return "Never" }
        return Constant.relativeDateTimeFormatter
            .localizedString(
                for: lastFollowedUpDate,
                   relativeTo: .now
            )
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
    private var contactButtons: some View {
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
                    CircularButton(icon: .pencil, action: .other(action: {
                        displayNativeContactModal(forID: contact.id)
                    }))
                }
            }
        }
    }

    @ViewBuilder
    private var followUpDetailsView: some View {
        HStack(spacing: 20) {
            Label("\(contact.followUps)", systemImage: Constant.Icon.thumbsUp.rawValue)
            Label(relativeTimeSinceFollowingUp, systemImage: Constant.Icon.personWithClock.rawValue)
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
    
    private var contactHeaderView: some View {
        VStack(spacing: Constant.ContactSheet.verticalSpacing) {
            
            contactBadgeAndNameView
            DateMetView(contact: contact)
            followUpDetailsView
            
            if let note = contact.note, !note.isEmpty {
                ContactNoteView(note: note)
                    .animation(.easeInOut, value: contact.note)
            }
            
            contactButtons
            
        }.padding(.top, 50)
    }
//    
//    private var reminderButtonView: some View {
//        
//    }
    
    var modalContactSheetView: some View {
        NavigationView {
            
            ZStack(alignment: .top) {

                ScrollView(.vertical) {
                    VStack(spacing: verticalSpacing) {
                        Spacer()
                        contactHeaderView
                        tagsView
                        Spacer()
                        startAConversationRowView
                        Spacer()
                        
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
            
            DateMetView(contact: contact)
            
            contactButtons
                .padding(.top)
            ActionButtonGridView(contact: contact, background: .clear)
                .padding([.top, .horizontal])
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Constant.cornerRadius)
    }
    
    @ViewBuilder
    private var variableContent: some View {
        switch kind {
        case .modal: modalContactSheetView
        case .inline: inlineContactSheetView
        }
    }

    var body: some View {
        variableContent
            .sheet(item: $nativeContactSheetID, onDismiss: {
                self.updateCurrentContact()
            }, content: {_ in
                NativeContactView(contactID: contact.id)
            })
    }
    
    // MARK: - Functions
    private func displayNativeContactModal(forID ID: String) {
        self.nativeContactSheetID = ID
    }
    
    private func updateCurrentContact() {
        followUpManager.contactsInteractor.updateContactInStore(withCNContactID: contact.id)
    }
    
}

struct ContactSheetView_Previews: PreviewProvider {
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
        .environmentObject(FollowUpStore.mocked())
    }
}
