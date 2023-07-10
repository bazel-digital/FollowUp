//
//  ContactListSectionView.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import SwiftUI

struct ContactListSectionView: View {

    // MARK: - Envirnment Values
    @EnvironmentObject var followUpManager: FollowUpManager
    
    // MARK: - Nested Enums
    enum LayoutDirection {
        case horizontal
        case vertical
    }
    
    // MARK: - Parameters
    var section: ContactSection
    var layoutDirection: LayoutDirection
    var minContactCardSize: CGFloat = Constant.ContactCard.minSize

    // MARK: - Stored Properties
    var verticalListRowItemEdgeInsets: EdgeInsets = .init(
        top: 5,
        leading: -20,
        bottom: 0,
        trailing: 0
    )
    
    // MARK: - Local State
    @State var expanded: Bool = true
    
    private var verticalSectionTitle: some View {
        Text("\(section.title)")
            .font(.headline)
            .padding(.bottom)
    }
    
    private var horizontalSectionTitle: some View {
        HStack {
            Text(section.grouping.title)
            Spacer()
            Circle()
                .frame(width: Constant.ContactList.newContactsBadgeSize, height: Constant.ContactList.newContactsBadgeSize)
                .foregroundColor(.red)
                .overlay {
                    Text("\(section.contacts.count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
        }
    }

    @ViewBuilder
    private func createHighlightToggleButton(for contact: any Contactable) -> some View {
        if !contact.highlighted {
            highlightButton(for: contact)
        }
        else {
            unhighlightButton(for: contact)
        }
    }

    private func highlightButton(for contact: any Contactable) -> some View {
        Button(action: {
            followUpManager.contactsInteractor.highlight(contact)
        }, label: {
            Label("Highlight", systemImage: "star.fill")
        })
        .tint(.yellow)
    }

    private func unhighlightButton(for contact: any Contactable) -> some View {
        Button(action: {
            followUpManager.contactsInteractor.unhighlight(contact)
        }, label: {
            Label("Unhighlight", systemImage: "star.slash.fill")
        })
        .tint(.yellow)
    }

    @ViewBuilder
    private func createAddToFollowUpsToggleButton(for contact: any Contactable) -> some View {
        if !contact.containedInFollowUps {
            addToFollowUpsButton(for: contact)
        } else {
            removeFromFollowUpsButton(for: contact)
        }
    }

    private func addToFollowUpsButton(for contact: any Contactable) -> some View {
        Button(action: {
            followUpManager.contactsInteractor.addToFollowUps(contact)
        }, label: {
            Label("Add to Follow Ups", systemImage: "plus")
        })
        .tint(.blue)
    }

    private func removeFromFollowUpsButton(for contact: any Contactable) -> some View {
        Button(action: {
            followUpManager.contactsInteractor.removeFromFollowUps(contact)
        }, label: {
            Label("Remove from Follow Ups", systemImage: "minus")
        })
        .tint(.red)
    }

    
    
    private var verticalContactList: some View {
        DisclosureGroup(isExpanded: $expanded, content: {
            ConditionalLazyVStack(lazy: section.contacts.count >= Constant.ContactList.maxContactsForNonLazyVStack) {
                ForEach(section.contacts, id: \.id) { contact in
                    ContactRowView(contact: contact)
                        .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                            createAddToFollowUpsToggleButton(for: contact)
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                            createHighlightToggleButton(for: contact)
                        })
                }
                .listRowInsets(.init(verticalListRowItemEdgeInsets))
            }
        }, label: {
            verticalSectionTitle
        })
        .accentColor(Color(.secondaryLabel))
        .padding(.horizontal)
    }
    
    private var horizontalContactList: some View {
        VStack {
            horizontalSectionTitle
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
            LazyVStack {
                ContactListSectionView(
                    section: .mocked(forGrouping: .relativeDate(grouping: .week)),
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
