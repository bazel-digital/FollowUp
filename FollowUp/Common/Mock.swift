//
//  Mock.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Fakery
import Foundation
import UIKit

struct MockedContact: Contactable {

    // MARK: - Stored Properties
    var id: String = UUID().uuidString
    var name: String
    var phoneNumber: PhoneNumber?
    var email: String?
    var thumbnailImage: UIImage?
    var note: String?
    var followUps: Int
    var createDate: Date
    var lastFollowedUp: Date?
    var highlighted: Bool
    var containedInFollowUps: Bool
    var lastInteractedWith: Date?

    init(id: String? = nil){
        let faker = Faker()
        if let id = id {
            self.id = id
        }
        self.name = faker.name.name()
        self.phoneNumber = .mocked
        self.email = faker.internet.email()
        self.note = faker.hobbit.quote()
        self.followUps = faker.number.randomInt(min: 0, max: 10)
        self.createDate = faker.date.backward(days: 30)
        self.lastFollowedUp = faker.date.backward(days: faker.number.randomInt(min: 0, max: 1))
        self.highlighted = faker.number.randomBool()
        self.containedInFollowUps = faker.number.randomBool()
        self.lastFollowedUp = faker.date.backward(days: 30)
        self.lastInteractedWith = faker.date.backward(days: 10)
    }

}

extension ContactSection {
    static func mocked(forGrouping grouping: Grouping) -> ContactSection {
        .init(contacts: (0...5).map { _ in MockedContact() }, grouping: grouping)
    }
}

extension Contactable where Self == Contact {
    static var mocked: Contactable { MockedContact() }
    static var mockedFollowedUpToday: Contactable {
        var contact = MockedContact()
        contact.lastFollowedUp = .now
        return contact
    }
}

extension PhoneNumber {
    static var mocked: PhoneNumber {
        PhoneNumber(from: "+44759768477")!
    }
}
