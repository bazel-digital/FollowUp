//
//  FollowUpError.swift
//  FollowUp
//
//  Created by Aaron Baw on 10/08/2023.
//

import Foundation

// MARK: -
enum FollowUpError: LocalizedError {
    
    // MARK: - Contacts Interactor
    case requestAccessError(Error?)
    case cnContactQueryError(Error?)
    case couldNotFindContact
    
    var id: String { self.title }
    
    var title: String {
        switch self {
        case .cnContactQueryError: return "Error Fetching Contacts"
        case .requestAccessError: return "Error Accessing Contacts"
        case .couldNotFindContact: return "Could Not Find Contact"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .cnContactQueryError(error): return error?.localizedDescription ?? ""
        case let .requestAccessError(error): return error?.localizedDescription ?? ""
        case .couldNotFindContact: return title
        }
    }
    
    var failureReason: String?  { self.errorDescription }

    var recoverySuggestion: String? {
        switch self {
        case .cnContactQueryError: return "Please send app feedback."
        case .requestAccessError: return "Ensure that the app has access to your contacts."
        case .couldNotFindContact: return "Please send app feedback."
        }
    }
}
