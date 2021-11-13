//
//  ContactSection.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

struct ContactSection: Identifiable {
    var id: String = UUID().uuidString
    let contacts: [Contact]
    let grouping: DateGrouping
    var expanded: Bool = false

    var title: String { "\(grouping.title)  (\(contacts.count))" }
}
