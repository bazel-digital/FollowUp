//
//  PhoneNumber.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import Foundation
import UIKit

struct PhoneNumber: Hashable, Codable {

    // MARK: - Static Properties
    static let numberFormatter = NumberFormatter()
    static let phoneNumberDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)

    // MARK: - Stored Properties
    var label: String? = nil
    var value: String

    var callURL: URL? {
        URL(string: "tel://\(value)")
    }

    var smsURL: URL? {
        URL(string: "sms://\(value)")
    }

    var whatsAppURL: URL? {
        URL(string:"https://api.whatsapp.com/send?phone=\(value)")
    }

    // MARK: - Initializer
    init?(
        from phoneNumberString: String,
        withLabel label: String? = nil
    ) {
        guard Self
                .phoneNumberDetector?
                .matches(
                    in: phoneNumberString,
                    options: [],
                    range: NSRange(
                        location: 0,
                        length: phoneNumberString.utf16.count
                    )
                ) != nil
        else { return nil }
        self.value = phoneNumberString
        self.label = label
    }
}
