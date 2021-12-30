//
//  ContactSheet.swift
//  FollowUp
//
//  Created by Aaron Baw on 29/12/2021.
//

import Foundation

struct ContactSheet: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let contactID: ContactID
    // TODO:
    // - Add background gradient / graphic which depends on the date in which the contact was met.
}
