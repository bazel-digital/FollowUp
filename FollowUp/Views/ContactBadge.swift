//
//  ContactBadge.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import SwiftUI

struct ContactBadge: View {

    // MARK: - Stored Properties
    var initials: String
    var backgroundGradientStartColour: Color = Color(.sRGB, white: 0.7, opacity: 1)
    var backgroundGradientEndColour: Color = .gray
    var size: Size = .small

    // MARK: - Enums
    enum Size {
        case small
        case large
        var fontSize: Font.TextStyle {
            switch self {
                case .small: return .body
                case .large: return .largeTitle
            }
        }
    }

    // MARK: - Computed Properties

    var padding: CGFloat {
        switch size {
        case .small: return Constant.ContactBadge.smallSizePadding
        case .large: return Constant.ContactBadge.largeSizePadding
        }
    }

    var body: some View {
        Text(initials)
            .font(.system(size.fontSize, design: .rounded))
            .foregroundColor(.white)
            .padding(padding)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient:
                                Gradient(colors: [
                                    backgroundGradientStartColour,
                                    backgroundGradientEndColour
                                ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
}

struct ContactBadge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactBadge(initials: "LD")
            ContactBadge(initials: "LD")
                .colorScheme(.dark)
            ContactBadge(initials: "LD")
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            ContactBadge(initials: "LD", size: .large)
        }.previewLayout(.sizeThatFits)
    }
}
