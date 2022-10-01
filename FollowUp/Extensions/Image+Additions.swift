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
        switch icon.kind {
        case .asset: self.init(icon.rawValue)
        case .sfSymbol: self.init(systemName: icon.rawValue)
        }
    }
}
