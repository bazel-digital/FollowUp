//
//  ConversationStarterTemplate.swift
//  FollowUp
//
//  Created by Aaron Baw on 26/01/2023.
//

import Foundation
import RealmSwift

// MARK: -
protocol ConversationStarting {
    func generateFormattedText(
        withContact contact: any Contactable
    ) async -> Result<String, Error>
    
    func generateFormattedText(
        withContact contact: any Contactable,
        completion: @escaping ((Result<String, Error>) -> Void)
    )
}

/// Standard conversation starter which uses a template message and replaces key words with their respective token values, such as `<NAME>`.
struct StandardConversationStarter: ConversationStarting {
    
    var template: String

    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
        .success(template.replacingOccurrences(of: "<NAME>", with: contact.firstName))
    }
    
    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
        completion(.success(template.replacingOccurrences(of: "<NAME>", with: contact.firstName)))
    }
}

/// Uses AI (ChatGPT) to generate customised conversation starter messages.
struct IntelligentConversationStarter: ConversationStarting {
    func generateFormattedText(withContact contact: any Contactable) async -> Result<String, Error> {
        <#code#>
    }
    
    func generateFormattedText(withContact contact: any Contactable, completion: @escaping ((Result<String, Error>) -> Void)) {
        <#code#>
    }
    
    
    var prompt: String
    var context: String?
}

// MARK: -
struct ConversationStarterTemplate: Codable, Hashable, Identifiable, CustomPersistable {
    
    typealias PersistedType = Data
    
    enum Platform: Codable, Hashable {
        case whatsApp

        var icon: Constant.Icon {
            switch self {
            case .whatsApp: return .whatsApp
            }
        }
    }
    
    enum Kind: Codable, Hashable, Equatable, CaseIterable {
        
        static var allCases: [ConversationStarterTemplate.Kind] = [.standard(template: ""), .intelligent(prompt: "", context: "")]
        
        case standard(template: String)
        case intelligent(prompt: String, context: String?)
        
        
        var template: String? {
            get {
                switch self {
                case let .standard(template): return template
                default: return nil
                }
            }
            set {
                switch self {
                case let .standard(template): self = .standard(template: newValue ?? template)
                default: return
                }
            }
        }
        
        var prompt: String? {
            get {
                switch self {
                case let .intelligent(prompt, _): return prompt
                default: return nil
                }
            }
            set {
                switch self {
                case let .intelligent(prompt, context): self = .intelligent(prompt: newValue ?? prompt, context: context)
                default: return
                }
            }
        }
        
        var context: String? {
            get {
                switch self {
                case let .intelligent(_, context): return context
                default: return nil
                }
            }
            set {
                switch self {
                case let .intelligent(prompt, context): self = .intelligent(prompt: prompt, context: newValue ?? context)
                default: return
                }
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .intelligent: return "Intelligent"
            case .standard: return "Standard"
            }
        }
        
        var icon: Constant.Icon {
            switch self {
            case .intelligent: return .chatWithWaveform
            case .standard: return .chatWithElipses
            }
        }
        
    }
    
    var label: String?
    var kind: Kind
    var platform: Platform
    var id: String
    static var encoder = JSONEncoder()
    static var decoder = JSONDecoder()
    
    var persistableValue: Data {
        (try? Self.encoder.encode(self)) ?? .init()
    }
    
    // MARK: - Computed Properties
    var title: String {
        guard let label = label, !label.isEmpty else {
            switch self.kind {
            case let .standard(template): return template
            case let.intelligent(prompt, _): return prompt
            }
        }
        return label
    }
    
    // MARK: - Initialisers
    init(persistedValue: Data) {
        let decodedObject = try? Self.decoder.decode(Self.self, from: persistedValue)
        self = decodedObject ?? .init(template: "", platform: .whatsApp)
    }
    
    /// Create a standard conversation starter.
    init(
        label: String? = nil,
        template: String,
        platform: Platform,
        id: String? = nil
    ) {
        self.kind = .standard(template: template)
        self.label = label
        self.platform = platform
        self.id = id
    }
    
    /// Create an intelligent conversation starter
    init(
        label: String? = nil,
        prompt: String,
        context: String?,
        platform: Platform,
        id: String = UUID().uuidString
    ) {
        self.kind = .intelligent(prompt: prompt, context: context)
        self.label = label
        self.platform = platform
        self.id = id ?? UUID().uuidString
    }
    
    // MARK: - Methods
    
    /// Uses the current template to create a conversation starter button action given the platform and contact.
    func buttonAction(
        contact: any Contactable
    ) throws -> ButtonAction? {
        switch self.platform {
        case .whatsApp:
            guard let number = contact.phoneNumber else { return nil }
//            let replacedString = try await generateFormattedText(withContact: contact)
            return .whatsApp(number: number, generateText: { completion in
                let contactCopy = contact.concrete
                generateFormattedText(withContact: contactCopy) { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            })
        }
    }
    
    func generateFormattedText(
        withContact contact: any Contactable
    ) async -> Result<String, Error> {
        switch self.kind {
        case let .standard(template):
            return .success(template.replacingOccurrences(of: "<NAME>", with: contact.firstName))
        case let .intelligent(prompt, context):
            let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
            do {
                let result = try await Networking.sendRequestToGPT3(prompt: requestString).value
                return .success(result)
            } catch {
                return .failure(StarterGenerationError.couldNotGenerate(error))
            }
        }
    }
    
    func generateFormattedText(
        withContact contact: any Contactable,
        completion: @escaping ((Result<String, Error>) -> Void)
    ) {
        switch self.kind {
        case let .standard(template):
             completion(.success(template.replacingOccurrences(of: "<NAME>", with: contact.firstName)))
        case let .intelligent(prompt, context):
            let requestString = self.constructChatGPTRequestString(for: contact, withPrompt: prompt, context: context)
            Networking.sendRequestToGPT3(prompt: requestString, completion: completion)
        }
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

// MARK: - Custom Errors
extension ConversationStarterTemplate {
    enum StarterGenerationError: Error {
        case couldNotGenerate(Error)
    }
}

// MARK: - Default Values
extension ConversationStarterTemplate {
    static var arrangeForCoffee: ConversationStarterTemplate {
        .init(label: "Arrange for coffee", template: "Hey <NAME>! How are you? I was wondering if you'd be free for a coffee this week?", platform: .whatsApp)
    }
    
    static var howAreYou: ConversationStarterTemplate {
        .init(label: "How are you?", template: "Hey <NAME>! How are you?", platform: .whatsApp)
    }
    
    static var examples: [ConversationStarterTemplate] = [
        .arrangeForCoffee,
        .howAreYou
    ]
}

