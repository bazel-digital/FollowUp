//
//  Text+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import Foundation
import SwiftUI

extension Text {
    init(_ localisedTextKey: LocalisedTextKey){
        self.init(localisedTextKey.rawValue)
    }
}
