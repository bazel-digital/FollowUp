//
//  ChipView.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/07/2023.
//

import SwiftUI

struct ChipView: View {
    
    // MARK: - Stored Properties
    var title: String
    var icon: Constant.Icon?
    var colour: Color = .red
    var action: (() -> Void)? = nil

    // MARK: - Views
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            Label(title: {
                Text(title)
            }, icon: {
                if let icon = icon {
                    Image(icon: icon)
                }
            })
        })
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, Constant.Tag.horiztontalPadding)
        .padding(.vertical, Constant.Tag.verticalPadding)
        .background(colour)
        .cornerRadius(Constant.Tag.cornerRadius)
    }
}

struct ChipView_Previews: PreviewProvider {
    static var previews: some View {
        ChipView(title: "Chip")
    }
}
