//
//  OnboardingView.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/05/2025.
//

import SwiftUI

struct OnboardingView: View {
    
    
    // MARK: - Stored Properties
    @Environment(\.dismiss) var onDismiss
    @State private var tabViewSelection: Int = 0
    var pages: [OnboardingPage] = Constant.Onboarding.defaultPages
    
    // MARK: - Computed Properties
    private var buttonString: String {
        tabViewSelection < (pages.count - 1) ? "Next" : "Done"
    }
    
    private var dismissDisabled: Bool {
        tabViewSelection != pages.count - 1
    }
    
    var body: some View {
        VStack {
            TabView(selection: $tabViewSelection) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page)
                        .tag(index)
                        .interactiveDismissDisabled(dismissDisabled)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            Button(action: {
                self.advancePage()
            }, label: {
                Text(buttonString)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .greatestFiniteMagnitude)
                .animation(.default, value: self.buttonString)
            })
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.blue)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .preferredColorScheme(.dark)
       }
    
    // MARK: - Functions
    private func advancePage(){
        if tabViewSelection < (pages.count-1) {
            withAnimation {
                self.tabViewSelection += 1
            }
        } else {
            self.onDismiss()
        }
    }
}

#Preview {
    OnboardingView()
}
