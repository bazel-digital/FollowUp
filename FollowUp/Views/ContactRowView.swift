//
//  ContactRowView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import SwiftUI

struct ContactRowView: View {

    // MARK: - Environment Objects
    @EnvironmentObject var followUpManager: FollowUpManager

    // MARK: - Stored Properties
    var contact: any Contactable
    var verticalPadding: CGFloat = Constant.verticalPadding
    var cornerRadius: CGFloat = Constant.cornerRadius
    var size: Constant.ContactBadge.Size = .small

    // MARK: - Computed Properties

    var name: String { contact.name }

    var image: UIImage? { contact.thumbnailImage }

    // MARK: - Views

    var followedUpMark: some View {
        Circle()
            .foregroundColor(.green)
            .frame(
                width: size.width + (size.padding*2),
                height: (size.width + size.padding*2)
            )
            .overlay(
                Image(icon: .checkmark)
                    .foregroundColor(.white)
            )
    }

    var rowContent: some View {
        HStack {

            if contact.hasBeenFollowedUpToday {
                followedUpMark
            } else {
                BadgeView(name: name, image: image, size: .small)
            }

            VStack(alignment: .leading) {
                Text(name)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if contact.hasBeenFollowedUpToday {
                Text("Followed Up today")
                    .foregroundColor(.secondary)
                    .font(.caption)
                }
            }
            Spacer()

            if let phoneNumber = contact.phoneNumber {
                CircularButton(icon: .phone, action: .call(number: phoneNumber))
                    .accentColor(.accentColor)
                CircularButton(icon: .sms, action: .sms(number: phoneNumber))
                .accentColor(.accentColor)
            }
        }
        .frame(maxWidth: .greatestFiniteMagnitude)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(cornerRadius)
    }

    var body: some View {
        Button(action: toggleContactModal, label: {
            rowContent
        })
        .accentColor(.primary)
    }

    // MARK: - Methods

    func toggleContactModal() {
        followUpManager.contactsInteractor.displayContactSheet(contact)
    }

    // MARK: - Initialisers

    init(
        name: String,
        phoneNumber: PhoneNumber? = nil,
        email: String? = nil,
        image: UIImage? = nil,
        note: String = "",
        createDate: Date = Date(),
        verticalPadding: CGFloat = Constant.verticalPadding,
        cornerRadius: CGFloat = Constant.cornerRadius
    ) {
        self.contact = Contact(
            name: name,
            phoneNumber: phoneNumber,
            email: email,
            thumbnailImage: image,
            note: note,
            createDate: createDate
        )
        self.verticalPadding = verticalPadding
        self.cornerRadius = cornerRadius
    }

    init(
        contact: any Contactable,
        verticalPadding: CGFloat = Constant.verticalPadding,
        cornerRadius: CGFloat = Constant.cornerRadius
    ) {
        self.contact = contact
        self.verticalPadding = verticalPadding
        self.cornerRadius = cornerRadius
    }
}

struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                ContactRowView(name: "Aaron Baw")
                ContactRowView(name: "A reallyreallyreallyreallyreallyreallylongname")
                ContactRowView(name: "Aaron Baw")
            }
            .padding()
            VStack {
                ContactRowView(name: "        Aaron    ")
                ContactRowView(contact: .mocked)
                ContactRowView(contact: .mockedFollowedUpToday)
                ContactRowView(contact: .mocked)
                ContactRowView(contact: .mocked)
                ContactRowView(contact: .mockedFollowedUpToday)
                ContactRowView(contact: .mocked)
                ContactRowView(contact: .mocked)
                ContactRowView(contact: .mockedFollowedUpToday)
                ContactRowView(contact: .mocked)
            }
            .padding()
            .preferredColorScheme(.dark)
        }.background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
