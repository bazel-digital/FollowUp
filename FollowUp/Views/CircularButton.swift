//
//  CircularButton.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import SwiftUI

struct CircularButton: View {

    // MARK: - Stored Properties
    var icon: Constant.Icon
    var action: () -> Void
    var padding: CGFloat = 10.0
    var accentColour: Color = .accentColor
    var backgroundOpacity: CGFloat = 0.3

    var body: some View {
        Button(action: action, label: {
            Image(systemName: icon.rawValue)
        })
            .accentColor(accentColour)
            .padding(padding)
            .background(accentColour.opacity(backgroundOpacity))
            .clipShape(Circle())
    }
}

struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularButton(icon: .phone, action: {})
    }
}
