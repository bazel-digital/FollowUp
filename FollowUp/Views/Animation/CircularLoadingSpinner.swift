//
//  CircularLoadingSpinner.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/03/2023.
//

import SwiftUI

struct CircularLoadingSpinner: View {
    
    var lineWidth: CGFloat = Constant.CircularLoadingSpinner.defaultLineWidth
    var backgroundCircleOpacity: CGFloat = Constant.CircularLoadingSpinner.defaultBackgroundCircleOpacity
    var colour: Color = Constant.CircularLoadingSpinner.defaultColour
    var showBackgroundCircle: Bool = false
    
    // MARK: - Aniamtable Data
    @State var rotation: Angle = .degrees(0)
    @State var trimEndPont: CGFloat = 1
    @State var trimStartPoint: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Circle
            if showBackgroundCircle {
                Circle()
                    .stroke(
                        colour.opacity(backgroundCircleOpacity),
                        lineWidth: lineWidth
                    )
            }
            
            // Overlay Circle
            Circle()
                .trim(from: trimStartPoint, to: trimEndPont)
                .stroke(
                    colour,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .animation(
                    .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                    value: trimEndPont
                )
                .rotationEffect(rotation)
                .animation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: rotation
                )
                .onAppear {
                    rotation = .degrees(360)
                    trimStartPoint = 0.4
                    trimEndPont = 0.6
                }
        }
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CircularLoadingSpinner()
            .frame(width: 50, height: 50)
    }
}
