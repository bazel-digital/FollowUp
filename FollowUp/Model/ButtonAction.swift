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
    case whatsApp(number: PhoneNumber, generateText: (@escaping (Result<String, Error>) -> Void) -> Void)
    case other(action: () -> Void)
    
    func closure(completion: ((Result<URL, Error>?) -> Void)? = nil) {
        switch self {
        case let .call(number):
            guard let callURL = number.callURL else { return }
            Log.info("Opening Call Link: \(callURL.absoluteString)")
            UIApplication.shared.open(callURL)
            completion?(.success(callURL))
        case let .sms(number):
            guard let smsURL = number.smsURL else { return }
            Log.info("Opening SMS Link: \(smsURL.absoluteString)")
            UIApplication.shared.open(smsURL)
            completion?(.success(smsURL))
        case let .whatsApp(number, generateText):
                generateText { (result: Result<String, Error>) in
                    switch result {
                    case let .success(text):
                        guard let whatsAppURL = number.whatsAppURL(withPrefilledText: text) else { return }
                        Log.info("Opening WhatsApp Link: \(whatsAppURL.absoluteString)")
                        UIApplication.shared.open(whatsAppURL)
                        completion?(.success(whatsAppURL))
                    case let .failure(error):
                        completion?(.failure(error))
                        Log.error("Could not generate text for WhatsApp link: \(error)")
                    }
                }
        case let .other(action):
            action()
            completion?(nil)
        }
    }
    
}
