//
//  Image+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import Foundation
import SwiftUI

extension Image {
    init(icon: Constant.Icon) {
        self.init(systemName: icon.rawValue)
    }
}
