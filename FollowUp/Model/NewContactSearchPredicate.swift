//
//  NewContactSearchPredicate.swift
//  FollowUp
//
//  Created by Aaron Baw on 10/07/2023.
//

import Foundation

enum NewContactSearchPredicate {
    /// Contacts met within a specific time frame.
    case metWithinTimeframe(RelativeDateGrouping)
    /// Contacts which have not yet been interacted with. These are displayed on the 'New' section on the NewContactsListView.
    case thatAreNew
}
