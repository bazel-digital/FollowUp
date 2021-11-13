//
//  ContactCardView.swift
//  FollowUp
//
//  Created by Aaron Baw on 31/10/2021.
//

import SwiftUI

struct ContactCardView: View {
    
    var contact: Contact
    var cornerRadius: CGFloat = Constant.cornerRadius
    
    var onAddToFollowUps: () -> Void = { }
    var onClose: () -> Void = { }

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
                ContactBadge(initials: contact.initials)
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
        .background(Color(.secondarySystemGroupedBackground))
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(cornerRadius)
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
