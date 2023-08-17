//
//  Log.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import Foundation
import OSLog

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
        
        var osLogType: OSLogType {
            switch self {
            case .error: return .error
            case .warn: return .default
            case .info: return .info
            }
        }
    }

    static func log(_ level: Level, message: String) {
        let message = "\(level.emoji) [\(level.rawValue.uppercased())] \(message)"
        print(message)
        
        let logObject = OSLog(subsystem: Constant.appIdentifier, category: "AppLogs")
        os_log("%{public}@", log: logObject, type: level.osLogType, message)
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
