//
//  Log.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import Foundation

enum Log {
    
    enum Level: String {
        case info
        case warn
        case error

        var emoji: String {
            switch self {
            case .info: return "ℹ️"
            case .warn: return "⚠️"
            case .error: return "❌"
            }
        }
    }

    static func log(_ level: Level, message: String) {
        print("\(level.emoji) [\(level.rawValue.uppercased())] \(message)")
    }

    static func info(_ message: String) {
        self.log(.info, message: message)
    }

    static func warn(_ message: String) {
        self.log(.warn, message: message)
    }

    static func error(_ message: String) {
        self.log(.error, message: message)
    }
}
