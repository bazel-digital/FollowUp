//
//  ContactModalView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactModalView: View {
    
    var contact: Contactable
    var onClose: () -> Void
    var verticalSpacing: CGFloat = Constant.ContactModal.verticalSpacing
    
    // MARK: - Computed Properties
    var relativeTimeSinceMeetingString: String {
        Constant.relativeDateTimeFormatter.localizedString(for: contact.createDate, relativeTo: .now)
    }
    
    private var relativeTimeSinceMeetingView: some View {
        (Text(Image(icon: .clock)) +
         Text(" Met ") +
         Text(relativeTimeSinceMeetingString))
            .fontWeight(.medium)
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
                    CircularButton(icon: .whatsApp, action: .whatsApp(number: phoneNumber))
                }
            }
        }
    }

    private var highlightButton: some View {
        Button(action: {}, label: {
            VStack {
                Image(icon: .star)
                Text("Highlight")
            }
        })
        .accentColor(.yellow)
    }

    private var followedUpButton: some View {
        Button(action: {}, label: {
            VStack {
                Image(icon: .thumbsUp)
                Text("I followed up")
            }
        })
        .accentColor(.green)
    }

    private var addToFollowUpsButton: some View {
        Button(action: {}, label: {
            VStack {
                Image(icon: .thumbsUp)
                Text("Add to follow ups")
            }
        })
    }

    private var actionButtonGrid: some View {
        LazyVGrid(columns: [
            .init(), .init(), .init()
        ], alignment: .center, content: {
  
            highlightButton
            addToFollowUpsButton
            followedUpButton
            
        })
    }
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            
            HStack {
                Spacer()
                CloseButton(onClose: onClose)
                    .padding([.top, .trailing])
            }
            
            Spacer()
            
            BadgeView(
                name: contact.name,
                image: contact.thumbnailImage,
                size: .large
            )
            Text(contact.name)
                .font(.largeTitle)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            if let note = contact.note, !note.isEmpty {
                Text(note)
                    .italic()
            }
            
            relativeTimeSinceMeetingView
            
            contactDetailsView
                .padding(.top)
            
            Spacer()
            
            actionButtonGrid
                .padding()
        }
    }
    
}

struct ContactModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactModalView(contact: MockedContact(), onClose: { })
            ContactModalView(contact: MockedContact(), onClose: { })
            ContactModalView(contact: Contact(
                name: "Estebon Julio Ricardo Montoya Rodriguez",
                phoneNumber: .init(from: "+44 738 737 2817", withLabel: "mobile"),
                email: "estebonjulioricardo@gmail.com",
                thumbnailImage: nil,
                note: "This is a long name!",
                createDate: Date()
            ),
                             onClose: { })
                .preferredColorScheme(.dark)
        }
    }
}
