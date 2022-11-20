//
//  CircularButton.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import SwiftUI

struct CircularButton: View {

    // MARK: - Environment Properties
    @Environment(\.openURL) var openURL

    // MARK: - Stored Properties
    var icon: Constant.Icon
    var action: ButtonAction
    var padding: CGFloat = 10.0
    var accentColour: Color = .accentColor
    var backgroundOpacity: CGFloat = 0.3

    var body: some View {
        Button(action: { action.closure() }, label: {
            Image(icon: icon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 15, height: 15, alignment: .center)
        })
            .accentColor(accentColour)
            .padding(padding)
            .background(accentColour.opacity(backgroundOpacity))
            .clipShape(Circle())
    }
}

struct CircularButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircularButton(icon: .phone, action: .other(action: {}))
            CircularButton(icon: .whatsApp, action: .other(action: {}))

        }.previewLayout(.sizeThatFits)
    }
}
