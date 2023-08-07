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
        ChipView(
            title: tag.title,
            icon: tag.icon,
            colour: tag.colour,
            action: action
        )
    }
}

struct TagChipView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TagChipView(tag: .init(title: "Science"))
//            TagChipView(tag: .mockedGym)
//            TagChipView(tag: .mockedAMS)

        }
    }
}
