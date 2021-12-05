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

    // MARK: - Views

    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .mask(Circle())
        }
    }

    var body: some View {
        ContactBadge(initials: initials, size: size)
            .overlay(
                imageView
            )
    }

}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BadgeView(name: "Aaron Baw")
            BadgeView(name: "Melissa Waterson", image: .init(named: "AppIcon"))

        }.previewLayout(.sizeThatFits)
    }
}
