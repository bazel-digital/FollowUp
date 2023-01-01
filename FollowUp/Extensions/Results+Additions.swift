//
//  Results+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 31/12/2022.
//

import Foundation
import RealmSwift

extension Results {
    var array: [Self.Element] {
        Array(self)
    }
}
