//
//  OnboardingPageView.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/05/2025.
//

import SwiftUI

struct OnboardingPageView: View {
    
    // MARK: - Environment Objects
    @EnvironmentObject var followUpManager: FollowUpManager
    
    // MARK: - Stored Properties
    let graphic: Constant.Graphic
    let title: String
    let description: String
    var onAppear: [OnboardingPage.Action] = []
    var onDisappear: [OnboardingPage.Action] = []

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Image(graphic: graphic)
                .resizable()
                .scaledToFit()
            Spacer()
            Text(description)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }.frame(maxWidth: .greatestFiniteMagnitude)
        .onAppear { perform(actions: onAppear) }
        .onDisappear { perform(actions: onDisappear) }
    }
    
    init(
        graphic: Constant.Graphic,
        title: String,
        description: String,
        onAppear: [OnboardingPage.Action] = [],
        onDisappear: [OnboardingPage.Action] = []
    ) {
        self.graphic = graphic
        self.title = title
        self.description = description
        self.onAppear = onAppear
        self.onDisappear = onDisappear
    }
    
    init(_ onboardingPage: OnboardingPage) {
        self.init(
            graphic: onboardingPage.graphic,
            title: onboardingPage.title,
            description: onboardingPage.description,
            onAppear: onboardingPage.onAppear,
            onDisappear: onboardingPage.onDisappear
        )
    }
    
    // MARK: - Functions
    
    private func perform(actions: [OnboardingPage.Action]) {
        actions.forEach(self.perform(action:))
    }
    
    func perform(action: OnboardingPage.Action) {
        switch action {
        case let .requestContactsPermission(delay):
            perform(after: delay) {
                self.followUpManager.contactsInteractor.fetchContacts()
            }
        case let .requestNotificationPermission(delay):
            perform(after: delay) {
                self.followUpManager.configureNotifications()
                
            }
        }
    }
    
    func perform(after delay: TimeInterval?, _ action: @escaping () -> Void) {
        guard let delay = delay else { return action() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
}

#Preview {
    OnboardingPageView(graphic: .onboardingContactTimeline, title: "Never lose touch again", description: "FollowUp helps you stay connected to the people that matter.")
}
