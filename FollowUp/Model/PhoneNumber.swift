//
//  PhoneNumber.swift
//  FollowUp
//
//  Created by Aaron Baw on 12/11/2021.
//

import Contacts
import Foundation
import RealmSwift
import UIKit

class PhoneNumber: Object, Codable {

    // MARK: - Static Properties
    static let numberFormatter = NumberFormatter()
    static let phoneNumberDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)

    // MARK: - Stored Properties
    @Persisted var label: String? = nil
    @Persisted var value: String

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

    func whatsAppURL(withPrefilledText prefilledText: String?) -> URL? {
        guard let parsedNumber = Int.parse(from: value) else { return nil }
        
        if let prefilledText = prefilledText,
           let urlEncodedString = prefilledText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return URL(string: "https://wa.me/\(parsedNumber)?text=\(urlEncodedString)")
        }
        
        return URL(string:"https://wa.me/\(parsedNumber)")
    }

    // MARK: - Initializer
    convenience init?(
        from phoneNumberString: String,
        withLabel label: String? = nil
    ) {
        self.init()
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
    
    convenience init?(_ phoneNumber: CNLabeledValue<CNPhoneNumber>?) {
        guard let phoneNumber = phoneNumber else { return nil }
        var label = phoneNumber.label

        if let labelValue = label, labelValue.hasPrefix("_$!<") == true {
            label = String(labelValue.dropFirst(4))
        }

        if let labelValue = label, labelValue.hasSuffix(">!$_") == true {
            label = String(labelValue.dropLast(4))
        }
        self.init(from: phoneNumber.value.stringValue, withLabel: label)
    }
}
