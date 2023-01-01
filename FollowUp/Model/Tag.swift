//
//  Tag.swift
//  FollowUp
//
//  Created by Aaron Baw on 14/06/2023.
//

import Foundation
import RealmSwift
import SwiftUI

class Tag: Object, Identifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var title: String
    @Persisted var colour: Color = .random()
    @Persisted var icon: Constant.Icon?
    
    convenience init(
        id: String? = nil,
        title: String,
        colour: Color? = nil,
        icon: Constant.Icon? = nil
    ) {
        self.init()
        self.id = id ?? self.id
        self.title = title
        self.colour = colour ?? self.colour
        self.icon = icon ?? self.icon
    }
}


#if DEBUG
extension Tag {
    static var mockedGym: Tag  = .init(title: "Gym", icon: .star)
    static var mockedAMS: Tag  = .init(title: "AMS", icon: .star)
}
#endif
