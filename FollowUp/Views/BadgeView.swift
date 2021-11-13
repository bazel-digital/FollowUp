//
//  BadgeView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct BadgeView: View {

    // MARK: - Stored Properties
    var name: String
    var image: UIImage?
    var size: ContactBadge.Size = .small

    // MARK:  - Computed Properties
    private var firstName: String { name.split(separator: " ").first?.capitalized ?? name }

    private var lastName: String { name.split(separator: " ").last?.capitalized ?? "" }

    var initials: String {
        (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
    }

    var body: some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
        } else {
            ContactBadge(initials: initials, size: size)
        }
    }

}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView(name: "Aaron Baw")
    }
}
