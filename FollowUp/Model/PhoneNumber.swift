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

    // MARK: - Computed Properties
    private var urlFriendlyValue: String {
        value.filter { !$0.isWhitespace }
    }

    var callURL: URL? {
        URL(string: "tel://\(urlFriendlyValue)")
    }

    var smsURL: URL? {
        URL(string: "sms://\(urlFriendlyValue)")
    }

    var whatsAppURL: URL? {
        guard let parsedInt = Int.parse(from: value) else { return nil }
        return URL(string:"https://wa.me/\(parsedInt)")
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
