//
//  Localisation.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import Foundation

enum LocalisedTextKey: String {
    
    // MARK: - FollowUps View
    case noHighlightsHeader = "No Highlights"
    case noHighlightsSubheader = "Tap the 'Highlight' button on a Contact sheet to add them to this list."
    
    // MARK: - New Contacts View
    case fetchingContactsHeader = "Fetching Contacts"
    
    case awaitingAuthorisationHeader = "Awaiting Authorisation"
    case awaitingAuthorisationSubheader = "Please allow FollowUp to read from your Contacts"
    
    case authorisationDeniedHeader = "Contacts Denied"
    case authorisationDeniedSubheader = "FollowUp needs permission to read from your device's contacts to work properly. Please enable this in Settings."
}
