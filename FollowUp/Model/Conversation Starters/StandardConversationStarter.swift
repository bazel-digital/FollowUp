//
//  StandardConversationStarter.swift
//  FollowUp
//
//  Created by Aaron Baw on 28/02/2023.
//

import Foundation

/// Standard conversation starter which uses a template message and replaces key words with their respective token values, such as `<NAME>`.
struct StandardConversationStarter: ConversationStarting {
    
    // MARK: - Stored Properties
    var template: String?
    let kind: ConversationStarterKind = .standard

    // Unused properties.
    var prompt: String? = nil
    var context: String? = nil
    
    // MARK: - Computed Properties
    var title: String { self.template ?? "" }
    
    // MARK: - Errors
    enum StandardConversationStarterError: Error {
        case couldNotUnwrapTemplate
    }

    // MARK: - Methods
    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
        guard let template = template else { return .failure(StandardConversationStarterError.couldNotUnwrapTemplate)}
        return .success(template.replacingOccurrences(of: Constant.ConversationStarter.Token.name.rawValue, with: contact.firstName))
    }
    
    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard let template = template else {
            return completion(.failure(StandardConversationStarterError.couldNotUnwrapTemplate))
        }
        return completion(.success(template.replacingOccurrences(of: Constant.ConversationStarter.Token.name.rawValue, with: contact.firstName)))
    }
}
