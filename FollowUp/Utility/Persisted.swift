//
//  File.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/12/2021.
//

import Foundation

@propertyWrapper struct Persisted<Value: Codable> {
    
    // MARK: - Stored Properties
    private let key: String

    private var currentStoredValue: Value

    var wrappedValue: Value {
        get {
            self.currentStoredValue
        }
        set {
            self.currentStoredValue = newValue
            Self.saveToUserDefaults(value: newValue, forKey: key)
        }
    }

    init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.currentStoredValue = Self.loadValueFromUserDefaults(forKey: key) ?? wrappedValue
    }

    // MARK: - Methods
    static func loadValueFromUserDefaults(forKey key: String) -> Value? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decodedValue = try? FollowUpApp.decoder.decode(Value.self, from: data)
        else { return nil }
        return decodedValue
    }

    static func saveToUserDefaults(value: Value, forKey key: String) {
        guard let encoded = try? FollowUpApp.encoder.encode(value) else { return }
        FollowUpApp.serialWriteQueue.async {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
