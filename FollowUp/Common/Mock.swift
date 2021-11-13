//
//  Mock.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Fakery
import Foundation
import UIKit

struct MockedContact: Contact {

    

    // MARK: - Stored Properties
    var id: String = UUID().uuidString
    var name: String
    var phoneNumber: PhoneNumber?
    var email: String?
    var thumbnailImage: UIImage?
    var note: String
    var followUps: Int
    var createDate: Date
    var highlighted: Bool
    var containedInFollowUps: Bool

    init(){
        let faker = Faker()
        self.name = faker.name.name()
        self.phoneNumber = PhoneNumber(from: faker.phoneNumber.phoneNumber())
        self.email = faker.internet.email()
        self.note = faker.hobbit.quote()
        self.followUps = faker.number.randomInt(min: 0, max: 10)
        self.createDate = faker.date.backward(days: 30)
        self.highlighted = faker.number.randomBool()
        self.containedInFollowUps = faker.number.randomBool()
    }

}

extension ContactSection {
    static func mocked(forGrouping grouping: DateGrouping) -> ContactSection {
        .init(contacts: (0...5).map { _ in MockedContact() }, grouping: grouping)
    }
}

extension Contact where Self == RecentContact {
    static var mocked: Contact { MockedContact() }
}
