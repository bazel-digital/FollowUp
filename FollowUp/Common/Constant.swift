//
//  Constant.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import CoreGraphics

enum Constant {
    
    // MARK: - Conversation Starters
    static var conversationStarters: [String] = [
        "Hey <NAME>! How's it going man?",
        "Hey <NAME>, hope you're well! Random, but I'm wondering if you'd like to come to church this Sunday?",
        "hey <NAME>, you up to much this weekend?",
        "hey, how's your week going?"
    ]

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
            case .checkmark, .clock, .close, .email, .minus, .phone, .plus, .sms, .star, .starWithText, .slashedStar, .thumbsUp, .personWithCheckmark, .partyPopper, .arrowCirclePath, .lock, .lockWithExclamationMark: return .sfSymbol
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
