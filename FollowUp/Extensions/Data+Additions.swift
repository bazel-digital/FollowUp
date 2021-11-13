//
//  Data+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Foundation
import UIKit

extension Data {
    var uiImage: UIImage? {
        UIImage(data: self)
    }
}
