//
//  Assertion+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 04/02/2023.
//

import Foundation

/// Assertion failure which falls through when running within the Canvas preview.
func assertionFailurePreviewSafe(_ message: String = "") {
    guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
        return
    }
    assertionFailure(message)
}
