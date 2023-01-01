//
//  Color+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 14/06/2023.
//

import Foundation
import RealmSwift
import SwiftUI

extension Color {
    static var allColours = [Color.black, .blue, .brown, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .yellow]
    
    static func random() -> Color {
        self.allColours.randomElement()!
    }
}

extension Color: CustomPersistable {
    
    public typealias PersistedType = String

    public init(persistedValue: String) {
        let components = persistedValue.split(separator: ",").compactMap { Float($0) }
        if components.count == 3 {
            self.init(red: Double(components[0]),
                      green: Double(components[1]),
                      blue: Double(components[2]))
        } else {
            assertionFailure("Could not initialise colour from persisted value: \(persistedValue)")
            self.init(uiColor: .clear)
        }
    }
    
    public var persistableValue: String {
        let color = UIColor(self)
        let red = color.cgColor.components?[0] ?? 0
        let green = color.cgColor.components?[1] ?? 0
        let blue = color.cgColor.components?[2] ?? 0
        return "\(red),\(green),\(blue)"
    }
    
}
