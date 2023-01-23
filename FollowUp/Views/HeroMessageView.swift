//
//  HeroMessageView.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import SwiftUI

struct HeroMessageView: View {
    
    // MARK: - Stored Properties
    var header: LocalisedTextKey
    var subheader: LocalisedTextKey?
    var icon: Constant.Icon
    
    // MARK: - Computed Properties
    var heroMessageVerticalSpacing: CGFloat { Constant.HeroMessage.verticalSpacing }
    var maxContentWidth: CGFloat { Constant.HeroMessage.maxContentWidth }
    
    // MARK: - Views
    var body: some View {
        VStack(
            alignment: .center,
            spacing: heroMessageVerticalSpacing
        ) {
            Group {
                Label(
                    header.rawValue,
                    systemImage: icon.rawValue
                )
                    .font(.headline)
                if let subheader = subheader {
                    Text(subheader)
                        .foregroundColor(.secondary)
                }
            }
            .frame(
                maxWidth: maxContentWidth
            )
        }
    }
}

struct HeroMessageView_Previews: PreviewProvider {
    static var previews: some View {
        HeroMessageView(
            header: .noHighlightsHeader,
            subheader: .noHighlightsSubheader,
            icon: .star
        )
    }
}
