//
//  ContactCardView.swift
//  FollowUp
//
//  Created by Aaron Baw on 31/10/2021.
//

import SwiftUI

struct ContactCardView: View {

    // MARK: - Environment
    @EnvironmentObject var followUpManager: FollowUpManager
    
    // MARK: - Stored Properties
    var contact: any Contactable
    var cornerRadius: CGFloat = Constant.cornerRadius

    @State private var contactModalDisplayed: Bool = false

    // MARK: - Computed Properties
    var relativeTimeSinceMeeting: String {
        Constant.relativeDateTimeFormatter.localizedString(for: contact.createDate, relativeTo: .now)
    }
    
    // MARK: - Views
    var nameAndTimeSinceView: some View {
        VStack(alignment: .leading) {
            Text(contact.name)
                .font(.headline)
            (
                Text(Image(icon: .clock)) +
                Text(" ") +
                Text(relativeTimeSinceMeeting)
            )
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
        }
        
    }
    
    var addToFollowUpsButton: some View {
        Button(action: {
            addToFollowUps()
        }, label: {
            (
                Text(Image(systemName: "plus")) +
                Text("Add to follow ups")
            )
            .fontWeight(.medium)

        })
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                BadgeView(name: contact.name, image: contact.thumbnailImage, size: .small)
                Spacer()
                CloseButton(onClose: { dismissNewContact() })
            }
            
            Spacer()
            nameAndTimeSinceView
            
            Spacer()
            Divider()
            addToFollowUpsButton
        }
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground)
                .onTapGesture {
                    self.toggleContactModal()
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Open")
        )
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(cornerRadius)
    }

    // MARK: - Methods

    func toggleContactModal() {
        followUpManager.contactsInteractor.displayContactSheet(contact)
    }

    func addToFollowUps() {
        followUpManager.contactsInteractor.addToFollowUps(contact)
    }

    func dismissNewContact() {
        followUpManager.contactsInteractor.dismiss(contact)
    }
}

struct ContactCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack {
                    ContactCardView(
                        contact: MockedContact()
                    )
                        .frame(maxWidth: geometry.size.width / 2)
                    ContactCardView(
                        contact: MockedContact()
                    )
                        .frame(maxWidth: geometry.size.width / 2)
                }.background(Color(.systemGroupedBackground))
                .environmentObject(FollowUpManager())
            }
        }
    }
}
