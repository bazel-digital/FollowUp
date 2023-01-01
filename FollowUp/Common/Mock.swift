//
//  Mock.swift
//  FollowUp
//
//  Created by Aaron Baw on 09/10/2021.
//

import Fakery
import Foundation
import RealmSwift
import UIKit

final class MockedContact: Object, Contactable {
    
    static let faker: Faker = .init()
    
    // MARK: - Stored Properties
//    @Persisted var _id: ObjectId = ObjectId()
    @Persisted var id: ContactID = UUID().uuidString
    @Persisted var name: String = faker.name.name()
    @Persisted var phoneNumber: PhoneNumber? = .mocked
    @Persisted var email: String? = faker.internet.email()
    @Persisted var tags: RealmSwift.List<Tag>
    var thumbnailImage: UIImage? = nil
    @Persisted var note: String? = faker.hobbit.quote()
    @Persisted var followUps: Int = faker.number.randomInt(min: 0, max: 10)
    @Persisted var createDate: Date = faker.date.backward(days: 30)
    @Persisted var lastFollowedUp: Date? = faker.date.backward(days: faker.number.randomInt(min: 0, max: 1))
    @Persisted var highlighted: Bool = faker.number.randomBool()
    @Persisted var containedInFollowUps: Bool = faker.number.randomBool()
    @Persisted var lastInteractedWith: Date? = faker.date.backward(days: 10)

    convenience init(id: String? = nil){
        self.init()
        self.id = id ?? self.id
    }

}

extension ContactSection {
    static func mocked(forGrouping grouping: Grouping) -> ContactSection {
        .init(contacts: (0...5).map { _ in MockedContact() }, grouping: grouping)
    }
}

extension Contactable where Self == Contact {
    static var mocked: any Contactable { MockedContact() }
    static var mockedFollowedUpToday: any Contactable {
        var contact = MockedContact()
        contact.lastFollowedUp = .now
        contact.tags.append(objectsIn: [Tag(title: "Gym"), Tag(title: "AMS")])
        return contact
    }
}

extension PhoneNumber {
    static var mocked: PhoneNumber {
        PhoneNumber(from: "+44759768477")!
    }
}
