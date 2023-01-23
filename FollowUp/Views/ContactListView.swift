//
//  ContactListView.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/01/2022.
//

import SwiftUI

struct ContactListView: View {

    // MARK: - Stored Properties
    var contactSetions: [ContactSection]

    var verticalListRowItemEdgeInsets: EdgeInsets = .init(
        top: 5,
        leading: -20,
        bottom: 0,
        trailing: 0
    )

    var emptyListRowItemEdgeInsets: EdgeInsets = .init(
        top: 0,
        leading: 0,
        bottom: 0,
        trailing: 0
    )

    // MARK: - Views
    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        List(contactSetions) { section in
            Section(content: {
                    ContactListSectionView(
                        section: section,
                        layoutDirection: section.grouping == .new ? .horizontal : .vertical
                    )
                    .listRowInsets(
                        .init(emptyListRowItemEdgeInsets)
                    )
            })
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

        }
        .listStyle(GroupedListStyle())
    }

}
struct ConsolidatedContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView(
            contactSetions: [
                .mocked(forGrouping: .new),
                .mocked(forGrouping: .date(grouping: .thisWeek)),
                .mocked(forGrouping: .date(grouping: .thisMonth))
            ]
        )
    }
}
