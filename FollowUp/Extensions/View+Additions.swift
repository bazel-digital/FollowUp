//
//  View+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import SwiftUI

extension View {
    func navigationBarColour(_ backgroundColour: UIColor, withTextColour: UIColor = .label) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColour))
    }
    
    // Credits: https://www.avanderlee.com/swiftui/error-alert-presenting/
    func errorAlert(error: Binding<FollowUpError?>, buttonTitle: String = "Ok") -> some View {
        return alert(Text(error.wrappedValue?.title ?? ""), isPresented: .constant(error.wrappedValue != nil), presenting: error.wrappedValue) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? error.localizedDescription)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
