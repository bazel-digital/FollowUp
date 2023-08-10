//
//  LocalizedAlertError.swift
//  FollowUp
//
//  Credits: https://www.avanderlee.com/swiftui/error-alert-presenting/
//
//  Created by Aaron Baw on 10/08/2023.
//

import Foundation

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
