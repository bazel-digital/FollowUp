//
//  EventTimelineItemView.swift
//  FollowUp
//
//  Created by Aaron Baw on 03/05/2025.
//

import SwiftUI

struct EventTimelineItemView: View {
    
    // MARK: - Stored Properties
    var item: TimelineItem

    var body: some View {
        VStack(alignment: .center) {
            Image(icon: item.icon)
                .padding(.bottom, 5)
            Text(item.title)
                .font(.footnote.bold())
            Text(item.time.formattedRelativeTimeSinceNow)
                .font(.footnote)

        }
        .foregroundStyle(.secondary)
        .padding()
    }
}

#Preview {
    EventTimelineItemView(item: .mockedCall)
}
