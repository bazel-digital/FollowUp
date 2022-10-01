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
        static let smallSize: CGSize = .init(width: 40, height: 40)
        static let largeSize: CGSize = .init(width: 80, height: 80)
    }

    // MARK: - Icons
    enum Icon: String {
        case checkmark = "checkmark"
        case clock = "clock.arrow.circlepath"
        case close = "xmark.circle.fill"
        case email = "envelope.fill"
        case minus = "minus"
        case phone = "phone.fill"
        case plus = "plus"
        case sms = "bubble.left.fill"
        case star = "star.fill"
        case starWithText = "text.badge.star"
        case slashedStar = "star.slash.fill"
        case thumbsUp = "hand.thumbsup.fill"
        case whatsApp = "whatsAppIcon"

        enum Kind {
            case asset
            case sfSymbol
        }

        var kind: Kind {
            switch self {
            case .checkmark, .clock, .close, .email, .minus, .phone, .plus, .sms, .star, .starWithText, .slashedStar, .thumbsUp, .thumbsUp: return .sfSymbol
            case .whatsApp: return .asset
            }
        }
    }

    // MARK: - Contact Card
    enum ContactCard {
        static let minSize: CGFloat = 200.0
    }

    // MARK: - Contact Sheet
    enum ContactSheet {
        static let verticalSpacing: CGFloat = 10.0
        static let maxHeight: CGFloat = 400.0
        static let noHighlightsViewMaxContentWidth: CGFloat = 250.0
    }

    // MARK: - Keys
    enum Key {
        static let followUpStore: String = "storage.FollowUpStore"

        enum FollowUpStore {
            static let contacts: String = "storage.FollowUpStore.contacts"
            static let contactDictionary: String = "storage.FollowUpStore.contactDictionary"
        }
    }
}
