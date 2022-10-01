//
//  HighlightsTabView.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/07/2022.
//

import SwiftUI

struct HighlightsTabView: View {
    var highlightedContacts: [Contact]
    var body: some View {
        TabView(content: {
            ForEach(highlightedContacts) {
                ContactSheetView(
                    kind: .inline,
                    sheet: $0.sheet,
                    onClose: {}
                )
                .padding()
            }
        })
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct HighlightsTabView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightsTabView(highlightedContacts: [.mocked.concrete, .mocked.concrete])
            .environmentObject(FollowUpManager())
            .background(.black)
    }
}
