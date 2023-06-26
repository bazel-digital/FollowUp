//
//  ContactSection.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

struct ContactSection: Identifiable {
    var id: String { grouping.title }
    let contacts: [any Contactable]
    let grouping: Grouping
    var expanded: Bool = false

    var title: String { "\(grouping.title)  (\(contacts.count))" }
}

// MARK: -
//extension ContactSection: Equatable {
//    static func == (lhs: ContactSection, rhs: ContactSection) -> Bool {
//        return lhs.contacts == rhs.contacts &&
//               lhs.grouping == rhs.grouping &&
//               lhs.expanded == rhs.expanded
//    }
//}
