//
//  ContactModalView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactModalView: View {
    
    // MARK: - Environment Values
    @Environment(\.openURL) var openURL
    
    var contact: Contact
    var onClose: () -> Void
    
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
            if let phoneNumber = contact.phoneNumber?.string {
                Text(phoneNumber)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            HStack {
                CircularButton(icon: .phone, action: callAction)
                CircularButton(icon: .sms, action: smsAction)
            }
        }
    }

    private var actionButtonGrid: some View {
        LazyVGrid(columns: [
            .init(), .init()
        ], alignment: .center, content: {
            Button(action: {}, label: {
                VStack {
                    Image(icon: .star)
                    Text("Highlight")
                }
            })
                .accentColor(.yellow)
            Button(action: {}, label: {
                VStack {
                    Image(icon: .thumbsUp)
                    Text("I followed up")
                }
            })
                .accentColor(.green)
        })
    }
    
    var body: some View {
        VStack {
            
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
            Text(contact.note)
            relativeTimeSinceMeetingView
            
            contactDetailsView
                .padding(.top)
            
            Spacer()

            actionButtonGrid
                .padding()
        }
    }
    
    // MARK: - Methods
    func callAction() {
        guard let phoneNumberURL = contact.phoneNumber?.callURL else { return }
        openURL(phoneNumberURL)
    }
    
    func smsAction() {
        guard let phoneNumberURL = contact.phoneNumber?.smsURL else { return }
        openURL(phoneNumberURL)
    }
}

struct ContactModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactModalView(contact: MockedContact(), onClose: { })
            ContactModalView(contact: MockedContact(), onClose: { })
                .preferredColorScheme(.dark)
        }
    }
}
