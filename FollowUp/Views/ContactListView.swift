//
//  ContactListView.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/01/2022.
//

import SwiftUI
import WrappingHStack

struct ContactListView: View {

    // MARK: - Stored Properties
    var contactSetions: [ContactSection]
    var suggestedTagSearchTokens: [Tag]
    @Binding var selectedTagSearchTokens: [Tag]
    @Environment(\.isSearching) var isSearching: Bool

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
    
    var prefixedSuggestedTagSearchTokens: [Tag] {
        self.suggestedTagSearchTokens
            .prefix(Constant.Search.maxNumberOfDisplayedSearchTagSuggestions)
            .map { $0 }
    }
    
    // MARK: - Computed Properties
    private var searchSuggestionView: some View {
        WrappingHStack(alignment: .leading) {
            ForEach(prefixedSuggestedTagSearchTokens) { tag in
                TagChipView(tag: tag, action: {
                    self.selectedTagSearchTokens.append(tag)
                })
            }
        }
        .animation(.default, value: suggestedTagSearchTokens)
        .padding(.horizontal)
        .padding(.top, Constant.Search.suggestedTagViewTopPadding)
        .background(Color(.systemGroupedBackground))
    }
    
    private var fullContactListView: some View {
        LazyVStack(spacing: Constant.ContactList.verticalSpacing) {
            ForEach(contactSetions) { section in
                ContactListSectionView(
                    section: section,
                    layoutDirection: section.grouping == .new ? .horizontal : .vertical
                )
                .padding(emptyListRowItemEdgeInsets)
            }
        }
        .background(Color.clear)
    }
    
    private var searchingContactListView: some View {
        LazyVStack(spacing: Constant.ContactList.verticalSpacing) {
            ForEach(contactSetions) { section in
                ContactListSectionView(
                    section: section,
                    layoutDirection: .vertical
                )
                .padding(emptyListRowItemEdgeInsets)
            }
        }
        .background(Color.clear)
    }

    // MARK: - Views
    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        
        ScrollView {
            if isSearching {
                searchSuggestionView
                    .transition(.opacity)
                searchingContactListView
            } else {
                fullContactListView
            }
        }
        .animation(.default, value: isSearching)
        .background(Color(.systemGroupedBackground))

    }

}
struct ConsolidatedContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView(
            contactSetions: [
                .mocked(forGrouping: .new),
                .mocked(forGrouping: .relativeDate(grouping: .week)),
                .mocked(forGrouping: .relativeDate(grouping: .month))
            ],
            suggestedTagSearchTokens: [],
            selectedTagSearchTokens: .constant([])
        )
    }
}
