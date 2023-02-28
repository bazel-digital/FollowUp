//
//  IntelligentConversationStarter.swift
//  FollowUp
//
//  Created by Aaron Baw on 28/02/2023.
//

import Foundation

/// Uses AI (ChatGPT) to generate customised conversation starter messages.
struct IntelligentConversationStarter: ConversationStarting {
    
    
    // MARK: - Stored Properties
    var prompt: String?
    var context: String?
    let kind: ConversationStarterKind = .intelligent
    
    // Unused properties.
    var template: String? = nil
    
    // MARK: - Computed Properties
    var title: String { self.prompt ?? "" }
    
    // MARK: - Errors
    enum IntelligentConversationStarterError: Error {
        case couldNotGenerate(Error)
        case couldNotUnwrapPrompt
    }

    // MARK: - Methods
    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
        guard let prompt = prompt else { return .failure(IntelligentConversationStarterError.couldNotUnwrapPrompt) }
        let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
        do {
            let result = try await Networking.sendRequestToGPT3(prompt: requestString).value
            return .success(result)
        } catch {
            return .failure(IntelligentConversationStarterError.couldNotGenerate(error))
        }
    }
    
    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard let prompt = prompt else { return completion(.failure(IntelligentConversationStarterError.couldNotUnwrapPrompt)) }
        let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
        Networking.sendRequestToGPT3(prompt: requestString, completion: completion)
    }
    
    private func constructChatGPTRequestString(for contact: any Contactable, withPrompt prompt: String, context: String?) -> String {
        
        var requestStringComponents: [String] = []
        
        requestStringComponents.append("I have a contact called \(contact.name).")
        
       if let contactNote: String = contact.note {
            requestStringComponents.append("Here's a description of the contact: \"\(contactNote)\"")
        }
        
        if let context = context {
            requestStringComponents.append("For some added context, \(context).")
        }
        
        requestStringComponents.append(prompt)
        
        return String(requestStringComponents.joined(separator: "\n\n"))
    }

}
