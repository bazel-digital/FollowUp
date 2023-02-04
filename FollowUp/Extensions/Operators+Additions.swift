//
//  Binding+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 26/01/2023.
//

import Foundation
import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
