//
//  ContactRowView.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import SwiftUI

struct ContactRowView: View {

    // MARK: - Stored Properties
    var contact: Contact
    var verticalPadding: CGFloat = Constant.verticalPadding
    var cornerRadius: CGFloat = Constant.cornerRadius

    @State private var contactModalDisplayed: Bool = false

    // MARK: - Computed Properties

    var name: String { contact.name }

    var image: UIImage? { contact.thumbnailImage }

    private var firstName: String { name.split(separator: " ").first?.capitalized ?? name }

    private var lastName: String { name.split(separator: " ").last?.capitalized ?? "" }

    var initials: String {
        (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
    }

    // MARK: - Views

    @ViewBuilder
    private var badge: some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
        } else {
            ContactBadge(initials: initials)
        }
    }

    var rowContent: some View {
        HStack {
            ContactBadge(initials: initials)
            Text(name)
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()

            if contact.phoneNumber != nil {
                CircularButton(icon: .phone, action: { })
                    .accentColor(.accentColor)
                CircularButton(icon: .sms, action: { })
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
            .sheet(isPresented: $contactModalDisplayed, content: {
                ContactModalView(
                    contact: contact,
                    onClose: toggleContactModal
                )
            })
    }

    // MARK: - Methods

    func toggleContactModal() {
        self.contactModalDisplayed.toggle()
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
        self.contact = RecentContact(
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
        contact: Contact,
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
                ContactRowView(contact: MockedContact())
                ContactRowView(contact: MockedContact())
                ContactRowView(contact: MockedContact())
            }
            .padding()
            .preferredColorScheme(.dark)
        }.background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
