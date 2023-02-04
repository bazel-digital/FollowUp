//
//  ConversationStarterTemplate.swift
//  FollowUp
//
//  Created by Aaron Baw on 26/01/2023.
//

import Foundation
import RealmSwift

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
    
    var label: String?
    var template: String
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
            return template
        }
        return label
    }
    
    // MARK: - Initialisers
    init(persistedValue: Data) {
        let decodedObject = try? Self.decoder.decode(Self.self, from: persistedValue)
        self = decodedObject ?? .init(template: "", platform: .whatsApp)
    }
    
    init(
        label: String? = nil,
        template: String,
        platform: Platform,
        id: String = UUID().uuidString
    ) {
        self.label = label
        self.template = template
        self.platform = platform
        self.id = id
    }
    
    // MARK: - Methods
    
    /// Uses the current template to create a conversation starter button action given the platform and contact.
    func buttonAction(
        contact: any Contactable
    ) -> ButtonAction? {
        switch self.platform {
        case .whatsApp:
            guard let number = contact.phoneNumber else { return nil }
            let replacedString = formattedText(withContact: contact)
            return .whatsApp(number: number, prefilledText: replacedString)
        }
    }
    
    func formattedText(
        withContact contact: any Contactable
    ) -> String {
        self.template.replacingOccurrences(of: "<NAME>", with: contact.firstName)
    }
}

