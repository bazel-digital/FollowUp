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
        case noMessageIncluded
        case couldNotUnwrapPrompt
    }

    // MARK: - Methods
//    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
//        guard let prompt = prompt else { return .failure(IntelligentConversationStarterError.couldNotUnwrapPrompt) }
//        let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
//        do {
//            let result = try await Networking.sendTextCompletionRequest(prompt: requestString).value
//            return .success(result)
//        } catch {
//            return .failure(IntelligentConversationStarterError.couldNotGenerate(error))
//        }
//    }
//
//    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
//        guard let prompt = prompt else { return completion(.failure(IntelligentConversationStarterError.couldNotUnwrapPrompt)) }
//        let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
//        Networking.sendTextCompletionRequest(prompt: requestString, completion: completion)
//    }
    
//    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
//
//    }
    
    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard let prompt = prompt else { return completion(.failure(IntelligentConversationStarterError.couldNotUnwrapPrompt)) }

        let promptString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
        let request = ChatCompletionRequest(model: .gpt35Turbo, messages: [
            .init(role: .system, content: "You are the AI behind a mobile app used to help users follow up with contacts. Your role is to write messages that can be sent on behalf of the user submitting the prompts. The platforms vary from WhatsApp to Messages. Respond only with the exact text that will be sent to the user, nothing else. You do not support chatting with the user, only fulfilling their request with a direct answer that can be copied and pasted into their messaging app. Make sure to use the information given by the user's prompt, and provided information about the contact in order to make each message personalised, relevant and relatable."),
            .init(role: .user, content: promptString)
        ])
        
        Networking.sendChatCompletionRequest(request, completion: { result in
            completion(result.tryMap {
                guard let responseString = $0.choices.first?.message.content else {
                    throw IntelligentConversationStarterError.noMessageIncluded
                }
                return responseString
            })
        })
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
