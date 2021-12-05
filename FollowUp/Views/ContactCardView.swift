//
//  ContactCardView.swift
//  FollowUp
//
//  Created by Aaron Baw on 31/10/2021.
//

import SwiftUI

struct ContactCardView: View {
    
    // MARK: - Stored Properties

    var contact: Contactable
    var cornerRadius: CGFloat = Constant.cornerRadius
    
    var onAddToFollowUps: () -> Void = { }
    var onClose: () -> Void = { }

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
            onAddToFollowUps()
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
                CloseButton(onClose: onClose)
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
        .sheet(isPresented: $contactModalDisplayed, content: {
            ContactModalView(contact: contact, onClose: toggleContactModal)
        })
    }

    // MARK: - Methods

    func toggleContactModal() {
        self.contactModalDisplayed.toggle()
    }
}

struct ContactCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack {
                    ContactCardView(contact: MockedContact())
                        .frame(maxWidth: geometry.size.width / 2)
                    ContactCardView(contact: MockedContact())
                        .frame(maxWidth: geometry.size.width / 2)
                }.background(Color(.systemGroupedBackground))
            }
        }
    }
}
