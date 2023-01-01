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
    
    // MARK: - Edit Conversastion Starter View
    case editConversationStarterName = "Name"
    case editConversationStarterChooseNameDescription = "Optional. Choose a short name for this conversation starter."
    
    case editConversationStarterMessageTitle = "Message"
    case editConversationStarterMessageDescription = "When writing your message template, use the <NAME> keyword and this will be replaced for the contact's first name when you use the conversation starter."
    
    case editConversationStarterSaveButtonTitle = "Save"
    
    // MARK: - Welcome Screen
    case welcomeScreenTitle = "Welcome to FollowUp"
    case welcomeScreenContinueButtonTitle = "Continue"
    
    // MARK: - Edit Tag
    case delete = "Delete"
}
