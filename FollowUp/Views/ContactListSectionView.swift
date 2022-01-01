//
//  ContactListSectionView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactListSectionView: View {
    
    // MARK: - Nested Enums
    enum LayoutDirection {
        case horizontal
        case vertical
    }
    
    // MARK: - Parameters
    var section: ContactSection
    var layoutDirection: LayoutDirection
    var minContactCardSize: CGFloat = Constant.ContactCard.minSize
    
    // MARK: - Local State
    @State var expanded: Bool = true
    
    private var sectionTitle: some View {
        Text("\(Image(icon: .clock)) \(section.title)")
            .font(.headline)
            .padding(.bottom)
    }
    
    private var verticalContactList: some View {
        DisclosureGroup(isExpanded: $expanded, content: {
            LazyVStack(alignment: .center) {
                ForEach(section.contacts, id: \.id) { contact in
                    ContactRowView(contact: contact)
                }
            }
        }, label: {
            sectionTitle
        })
            .accentColor(Color(.secondaryLabel))
            .padding(.horizontal)
    }
    
    private var horizontalContactList: some View {
        VStack {
            sectionTitle
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(section.contacts, id: \.id) { contact in
                        ContactCardView(contact: contact)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(minWidth: minContactCardSize, minHeight: minContactCardSize)
                    }
                }
                .padding(.horizontal)
            }
        }
        .animation(.easeInOut, value: 1)
    }
    
    var body: some View {
        switch layoutDirection {
        case .horizontal:
            horizontalContactList
        case .vertical:
            verticalContactList
        }
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                ContactListSectionView(
                    section: .mocked(forGrouping: .date(grouping: .thisWeek)),
                    layoutDirection: .horizontal
                )
                ContactListSectionView(
                    section: .mocked(forGrouping: .new),
                    layoutDirection: .vertical
                )
            }.background(Color(.systemGroupedBackground))
        }
    }
}
