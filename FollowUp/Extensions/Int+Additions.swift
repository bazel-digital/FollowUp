//
//  Int+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import Foundation

// CREDIT: https://stackoverflow.com/a/41454516
extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
