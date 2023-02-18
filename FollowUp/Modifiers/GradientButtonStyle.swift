//
//  GradientButtonStyle.swift
//  FollowUp
//
//  Created by Aaron Baw on 18/02/2023.
//

import Foundation
import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    
    var colours: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(Constant.borderedButtonPadding)
            .background {
                LinearGradient(colors: colours, startPoint: .leading, endPoint: .trailing)
                    .opacity(configuration.isPressed ? 0.75 : 1)
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
            .foregroundColor(.white.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Constant.buttonCornerRadius))
    }
}
