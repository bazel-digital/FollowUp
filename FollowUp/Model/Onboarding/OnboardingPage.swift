//
//  OnboardingPage.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/05/2025.
//

import Foundation

struct OnboardingPage: Identifiable {
    
    // MARK: - Enum
    enum Action {
        case requestNotificationPermission(delay: TimeInterval?)
        case requestContactsPermission(delay: TimeInterval?)
    }
    
    // MARK: - Stored Properties
    let id: String = UUID().uuidString
    let graphic: Constant.Graphic
    let title: String
    let description: String
    var onAppear: [Action] = []
    var onDisappear: [Action] = []
}
