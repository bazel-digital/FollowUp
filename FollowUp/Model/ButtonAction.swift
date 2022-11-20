//
//  ButtonAction.swift
//  FollowUp
//
//  Created by Aaron Baw on 01/10/2022.
//

import Foundation
import UIKit

enum ButtonAction {
    case sms(number: PhoneNumber)
    case call(number: PhoneNumber)
    case whatsApp(number: PhoneNumber, prefilledText: String?)
    case other(action: () -> Void)

    var closure: () -> Void {
        switch self {
        case let .call(number):
            guard let callURL = number.callURL else { return {  } }
            Log.info("Opening Call Link: \(callURL.absoluteString)")
            return { UIApplication.shared.open(callURL) }
        case let .sms(number):
            guard let smsURL = number.smsURL else { return {} }
            Log.info("Opening SMS Link: \(smsURL.absoluteString)")
            return { UIApplication.shared.open(smsURL) }
        case let .whatsApp(number, prefilledText):
            guard let whatsAppURL = number.whatsAppURL(withPrefilledText: prefilledText) else { return {} }
            Log.info("Opening WhatsApp Link: \(whatsAppURL.absoluteString)")
            return { UIApplication.shared.open(whatsAppURL) }
        case let .other(action):
            return action
        }
    }

    var text: String? {
        switch self {
        case let .whatsApp(_, prefilledText): return prefilledText
        default: return nil
        }
    }
}
