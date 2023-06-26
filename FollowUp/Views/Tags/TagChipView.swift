//
//  TagChipView.swift
//  FollowUp
//
//  Created by Aaron Baw on 14/06/2023.
//

import SwiftUI

struct TagChipView: View {
    
    // MARK: - Stored Properties
    var tag: Tag
    var action: (() -> Void)? = nil
    
    // MARK: - Computed Properties
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            Label(title: {
                Text(tag.title)
            }, icon: {
                if let icon = tag.icon {
                    Image(icon: icon)
                }
            })
        })
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, Constant.Tag.horiztontalPadding)
        .padding(.vertical, Constant.Tag.verticalPadding)
        .background(tag.colour)
        .cornerRadius(Constant.Tag.cornerRadius)
    }
}

struct TagChipView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TagChipView(tag: .init(title: "Science"))
            TagChipView(tag: .mockedGym)
            TagChipView(tag: .mockedAMS)

        }
    }
}
