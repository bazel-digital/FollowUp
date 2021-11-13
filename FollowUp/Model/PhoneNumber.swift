//
//  PhoneNumber.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import Foundation

struct PhoneNumber {

    // MARK: - Static Properties
    static let numberFormatter = NumberFormatter()
    static let phoneNumberDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)

    // MARK: - Stored Properties
    var string: String

    var callURL: URL? {
        URL(string: "tel://\(string)")
    }

    var smsURL: URL? {
        URL(string: "sms://\(string)")

    }

    // MARK: - Initializer
    init?(
        from phoneNumberString: String
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
        self.string = phoneNumberString
    }
}
