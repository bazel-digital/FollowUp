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
        
        enum Size {
            case small
            case large
            
            var width: CGFloat {
                switch self {
                case .small: return 23
                case .large: return 50
                }
            }
            
            var padding: CGFloat {
                switch self {
                case .small: return 10.0
                case .large: return 20.0
                }
            }
        }

    }

    // MARK: - Icons
    enum Icon: String {
        case chatBubbles = "bubble.left.and.bubble.right.fill"
        case checkmark = "checkmark"
        case chevronRight = "chevron.right"
        case clock = "clock.arrow.circlepath"
        case close = "xmark.circle.fill"
        case closeOutline = "xmark"
        case email = "envelope.fill"
        case minus = "minus"
        case phone = "phone.fill"
        case plus = "plus"
        case settings = "gearshape.fill"
        case sms = "bubble.left.fill"
        case star = "star.fill"
        case starWithText = "text.badge.star"
        case slashedStar = "star.slash.fill"
        case thumbsUp = "hand.thumbsup.fill"
        case whatsApp = "whatsAppIcon"
        case personWithCheckmark = "person.crop.circle.fill.badge.checkmark"
        case partyPopper = "party.popper.fill"
        case arrowCirclePath = "arrow.triangle.2.circlepath"
        case lock = "lock.fill"
        case lockWithExclamationMark = "lock.trianglebadge.exclamationmark"

        enum Kind {
            case asset
            case sfSymbol
        }

        var kind: Kind {
            switch self {
            case .chatBubbles, .checkmark, .chevronRight, .clock, .closeOutline, .close, .email, .minus, .phone, .plus, .settings, .sms, .star, .starWithText, .slashedStar, .thumbsUp, .personWithCheckmark, .partyPopper, .arrowCirclePath, .lock, .lockWithExclamationMark: return .sfSymbol
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
    
    // MARK: - Hero Message
    enum HeroMessage {
        static let verticalSpacing: CGFloat = 10.0
        static let maxContentWidth: CGFloat = 250.0
    }

    // MARK: - Conversation Action Button
    enum ConversationActionButton {
        static let maxWidth: CGFloat = 200.0
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
