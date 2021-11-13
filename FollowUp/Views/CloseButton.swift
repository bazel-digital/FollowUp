//
//  CloseButton.swift
//  FollowUp
//
//  Created by Aaron Baw on 11/11/2021.
//

import SwiftUI

struct CloseButton: View {

    // MARK: - Stored Properties
    var onClose: () -> Void
    var size: CGFloat = 25.0

    var body: some View {
        Button(action: {
            onClose()
        }, label: {
            Image(icon: .close)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.secondary)
                .frame(width: size, height: size, alignment: .center)
        })
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(onClose: { })
    }
}
