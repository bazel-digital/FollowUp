//
//  Constant.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import CoreGraphics
import SwiftUI
import RealmSwift

enum Constant {

    // MARK: - Padding
    static let verticalPadding: CGFloat = 10.0

    // MARK: - Misc
    static let cornerRadius: CGFloat = 15.0
    static let buttonCornerRadius: CGFloat = 8.0
    static let borderedButtonPadding: CGFloat = 15.0

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
    enum Icon: String, PersistableEnum {
        case bolt = "bolt.fill"
        case chatBubbles = "bubble.left.and.bubble.right.fill"
        case chatWithElipses = "ellipsis.message.fill"
        case chatWithWaveform = "message.and.waveform.fill"
        case checkmark = "checkmark"
        case chevronRight = "chevron.right"
        case clock = "clock.arrow.circlepath"
        case close = "xmark.circle.fill"
        case closeOutline = "xmark"
        case email = "envelope.fill"
        case minus = "minus"
        case partyPopper = "party.popper.fill"
        case personWithCheckmark = "person.crop.circle.fill.badge.checkmark"
        case personWithDescription = "person.text.rectangle.fill"
        case phone = "phone.fill"
        case plus = "plus"
        case settings = "gearshape.fill"
        case sms = "bubble.left.fill"
        case star = "star.fill"
        case starWithText = "text.badge.star"
        case slashedStar = "star.slash.fill"
        case target = "target"
        case thumbsUp = "hand.thumbsup.fill"
        case trash = "trash.fill"
        case whatsApp = "whatsAppIcon"

        case arrowCirclePath = "arrow.triangle.2.circlepath"
        case lock = "lock.fill"
        case lockWithExclamationMark = "lock.trianglebadge.exclamationmark"
        
        static let mediumSize: CGFloat = 30.0

        enum Kind {
            case asset
            case sfSymbol
        }

        var kind: Kind {
            switch self {
            case .bolt, .chatBubbles, .chatWithElipses, .chatWithWaveform, .checkmark, .chevronRight, .clock, .closeOutline, .close, .email, .minus, .partyPopper, .personWithCheckmark, .personWithDescription, .phone, .plus, .settings, .sms, .star, .starWithText, .slashedStar, .target, .thumbsUp, .trash, .personWithCheckmark, .partyPopper, .arrowCirclePath, .lock, .lockWithExclamationMark: return .sfSymbol
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
        static let noteViewMaxHeight: CGFloat = 150.0
        static let bottomPaddingForFollowUpDetails: CGFloat = 120.0
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
    
    // MARK: - Circular Loading Spiner
    enum CircularLoadingSpinner {
        static let defaultSize: CGFloat = 25.0
        static let defaultLineWidth: CGFloat = 5.0
        static let defaultBackgroundCircleOpacity: CGFloat = 0.50
        static let defaultColour: Color = .blue
    }
    
    // MARK: - Tags
    enum Tag {
        static let horiztontalPadding: CGFloat = 10.0
        static let verticalPadding: CGFloat = 5.0
        static let cornerRadius: CGFloat = 5.0
    }

    // MARK: - Keys
    enum Key {
        static let followUpStore: String = "storage.FollowUpStore"

        enum FollowUpStore {
            static let contacts: String = "storage.FollowUpStore.contacts"
            static let contactDictionary: String = "storage.FollowUpStore.contactDictionary"
        }
    }
    
    // MARK: - Contact List
    enum ContactList {
        static let maxContactsForNonLazyVStack: Int = 20
        static let verticalSpacing: CGFloat = 20.0
    }
    
    // MARK: - Search
    enum Search {
        static let contactSearchDebounce: RunLoop.SchedulerTimeType.Stride = 0.5
        static let tagSearchDebounce: RunLoop.SchedulerTimeType.Stride = 0.1
        static let maxNumberOfDisplayedSearchTagSuggestions: Int = 9
        static let suggestedTagViewTopPadding: CGFloat = 7.0
    }
    
    
    // MARK: - Secrets
    enum Secrets {
        static let openAIUserDefaultsKey: String = "openAIKey"
    }
    
    // MARK: - Conversation Starter
    enum ConversationStarter {
        
        enum Token: String, CaseIterable {
            case name = "<NAME>"
            
            var title: String {
                switch self {
                case .name: return "Name"
                }
            }
        }
        
        static let defaultMaxTokenGenerationLength: Int = 1000
    }
}
