//
//  FollowUpsView.swift
//  FollowUp
//
//  Created by Aaron Baw on 30/12/2021.
//

import SwiftUI

struct FollowUpsView: View {

    // MARK: - Properties
    var contactSheetMaxHeight: CGFloat { Constant.ContactSheet.maxHeight }

    var noHighlightsViewVerticalSpacing: CGFloat { Constant.ContactSheet.verticalSpacing }

    var noHighlightsViewMaxContentWidth: CGFloat { Constant.ContactSheet.noHighlightsViewMaxContentWidth }

    // MARK: - Environment Objects
    @EnvironmentObject var followUpManager: FollowUpManager

    // MARK: - Computed Properties
    var highlightedContacts: [Contact] {
        followUpManager.store.highlightedContacts.map(\.concrete)
    }

    private var sortedContacts: [any Contactable] {
        followUpManager
                    .store
                    .followUpContacts
                    .sorted(by: \.createDate)
                    .reversed()
    }

    private var contactSections: [ContactSection] {
        sortedContacts
            .grouped(by: \.grouping)
            .map { grouping, contacts in
                .init(
                    contacts: contacts
                        .sorted(by: \.createDate)
                        .reversed(),
                    grouping: grouping
                )
            }
            .sorted(by: \.grouping)
    }

    // MARK: - Views

    private var noHighlightsView: some View {
        VStack(alignment: .center, spacing: noHighlightsViewVerticalSpacing) {
            Group {
                Label(
                    "No Highlights",
                    systemImage: Constant.Icon.starWithText.rawValue
                )
                    .font(.headline)
                Text("Tap the 'Highlight' button on a Contact sheet to add them to this list.")
                    .foregroundColor(.secondary)
            }
            .frame(
                maxWidth: noHighlightsViewMaxContentWidth
            )
        }
        .frame(
            maxWidth: .infinity,
            idealHeight: contactSheetMaxHeight
        )
        .padding()
        .cornerRadius(Constant.cornerRadius)
        .padding()
    }

    @ViewBuilder
    private var highlightsSectionView: some View {
        VStack {
            HStack {
                Text("Highlights")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(highlightedContacts.count)")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding()

            HighlightsTabView(highlightedContacts: highlightedContacts)
                .frame(height: contactSheetMaxHeight)
        }
    }

    private var followUpsSectionView: some View {
        LazyVStack {
            ForEach(contactSections) { section in
                ContactListSectionView(
                    section: section,
                    layoutDirection: section.grouping == .new ? .horizontal : .vertical
                )
            }
            .padding(.vertical)
        }
    }

    var body: some View {
        ScrollView {
            
            DailyGoalView(
                followUps: followUpManager.store.followedUpToday,
                dailyGoal: followUpManager.store.dailyFollowUpGoal
            ).padding()

            if highlightedContacts.isEmpty {
                noHighlightsView
            } else {
                highlightsSectionView
            }

            followUpsSectionView

        }
        .background(Color(.systemGroupedBackground))
//        .animation(.easeInOut, value: highlightedContacts.count + sortedContacts.count)
    }
}

struct FollowUpsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FollowUpsView()
                .environmentObject(FollowUpManager(store: .mocked()))
//            FollowUpsView()
//                .environmentObject(FollowUpManager(store: .mocked(withNumberOfContacts: 0)))
        }
    }
}
