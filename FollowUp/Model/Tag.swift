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
    @Persisted var colour: Color = .random()
    @Persisted var icon: Constant.Icon?
    @Persisted(originProperty: "tags") var taggedContacts: LinkingObjects<Contact>

    var title: String { id }
    
    convenience init(
        title: String,
        colour: Color? = nil,
        icon: Constant.Icon? = nil
    ) {
        self.init()
        self.id = title.trimmingWhitespace()
        self.colour = colour ?? self.colour
        self.icon = icon ?? self.icon
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Tag else {
            return false
        }
        
        return !self.isInvalidated && (self.id == object.id)
    }
}


#if DEBUG
extension Tag {
    static var mockedGym: Tag  = .init(title: "Gym", icon: .star)
    static var mockedAMS: Tag  = .init(title: "AMS", icon: .star)
}
#endif
