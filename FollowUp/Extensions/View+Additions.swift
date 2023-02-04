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
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
