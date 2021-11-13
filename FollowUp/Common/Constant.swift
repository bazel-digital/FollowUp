//
//  Constant.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import CoreGraphics

enum Constant {

    // MARK: - Padding
    static let verticalPadding: CGFloat = 10.0

    // MARK: - Misc
    static let cornerRadius: CGFloat = 15.0

    // MARK: - Date Formatting
    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = .init()

    // MARK: - Round Badge
    enum ContactBadge {
        static let smallSizePadding: CGFloat = 10.0
        static let largeSizePadding: CGFloat = 20.0
    }

    // MARK: - Icons
    enum Icon: String {
        case clock = "clock.arrow.circlepath"
        case close = "xmark.circle.fill"
        case email = "envelope.fill"
        case phone = "phone.fill"
        case sms = "bubble.left.fill"
        case star = "star.fill"
        case thumbsUp = "hand.thumbsup.fill"

    }

    // MARK: - Contact Card
    enum ContactCard {
        static let minSize: CGFloat = 200.0
    }
}
