//
//  String+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/03/2023.
//

import Foundation

extension String {
    func fuzzyMatch(_ pattern: String) -> Bool {
        var index = self.startIndex
        for char in pattern {
            if let range = self[index...].range(of: "\(char)", options: .caseInsensitive) {
                index = range.upperBound
            } else {
                return false
            }
        }
        return true
    }
    
    func trimmingWhitespace() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
