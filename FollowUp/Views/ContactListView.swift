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

    // MARK: - Views
    var body: some View {
        List(contactSetions) { section in
            Section(content: {
                    ContactListSectionView(
                        section: section,
                        layoutDirection: section.grouping == .new ? .horizontal : .vertical
                    )
            })
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(
                .init(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
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
