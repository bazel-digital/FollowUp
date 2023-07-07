//
//  ConversationStarting.swift
//  FollowUp
//
//  Created by Aaron Baw on 28/02/2023.
//

import Foundation

// MARK: -
protocol ConversationStarting: Codable, Equatable, Hashable {
    
    var title: String { get }
    var kind: ConversationStarterKind { get }
    
    var template: String? { get set }
    var prompt: String? { get set }
    var context: String? { get set }
    
    func generateFormattedText(
        withContact contact: any Contactable,
        completion: @escaping ((Result<String, Error>) -> Void)
    )
}

// MARK: - Equality Extension
extension ConversationStarting {
    func equals(_ other: any ConversationStarting) -> Bool {
        if let thisStarter = self as? StandardConversationStarter, let otherStarter = other as? StandardConversationStarter {
            return thisStarter ==  otherStarter
        }
        
        if let thisStarter = self as? IntelligentConversationStarter, let otherStarter = other as? IntelligentConversationStarter {
            return thisStarter == otherStarter
        }
        return false
    }
}
