//
//  ContactsInteractor.swift
//  FollowUp
//
//  Created by Aaron Baw on 10/10/2021.
//

import AddressBook
import Combine
import Contacts
import Foundation
import SwiftUI
import Fakery

// MARK: - Typealiases
typealias ContactID = String

// MARK: -
protocol ContactsInteracting {
    var contactsPublisher: AnyPublisher<[Contactable], Never> { get }
    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { get }
    var contactSheet: ContactSheet? { get }
    func fetchContacts() async
    func highlight(_ contact: Contactable)
    func unhighlight(_ contact: Contactable)
    func addToFollowUps(_ contact: Contactable)
    func removeFromFollowUps(_ contact: Contactable)
    func markAsFollowedUp(_ contact: Contactable)
    func displayContactSheet(_ contact: Contactable)
    func hideContactSheet()
}

// MARK: -
class ContactsInteractor: ContactsInteracting, ObservableObject {

    // MARK: - Static Properties
    public static var shared: ContactsInteracting = ContactsInteractor()

    // MARK: - Private Properties
    private var _contactsPublisher: PassthroughSubject<[Contactable], Never> = .init()

    // MARK: - Public Properties
    var contactsPublisher: AnyPublisher<[Contactable], Never> { _contactsPublisher.eraseToAnyPublisher() }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { self.$contactSheet.eraseToAnyPublisher() }

    @Published var contactSheet: ContactSheet?

    // MARK: - Public Methods
    func highlight(_ contact: Contactable) {
        var contact = contact.concrete
        contact.highlighted = true
        self._contactsPublisher.send([contact])
    }

    func unhighlight(_ contact: Contactable) {
        var contact = contact.concrete
        contact.highlighted = false
        self._contactsPublisher.send([contact])
    }

    func addToFollowUps(_ contact: Contactable) {
        var contact = contact.concrete
        contact.containedInFollowUps = true
        self._contactsPublisher.send([contact])
    }

    func removeFromFollowUps(_ contact: Contactable) {
        var contact = contact.concrete
        contact.containedInFollowUps = false
        self._contactsPublisher.send([contact])
    }

    func markAsFollowedUp(_ contact: Contactable) {
        var contact = contact.concrete
        contact.followUps += 1
        self._contactsPublisher.send([contact])
    }

    func displayContactSheet(_ contact: Contactable) {
        self.contactSheet = contact.sheet
    }

    func hideContactSheet() {
        self.contactSheet = nil
    }
}

// MARK: - Fetch Logic Extension
extension ContactsInteractor {
    
    // MARK: - Public Methods
    public func fetchContacts() async {
        // await self.fetchCNContacts()
        self.fetchABContacts()
    }
    
    // MARK: - Private Methods
    private func fetchCNContacts() async {
        print("Fetching contacts.")
        let contactStore = CNContactStore()
        guard
            let authorizationResult = try? await contactStore.requestAccess(for: .contacts),
            authorizationResult,
            let fetchedContacts = try? contactStore.unifiedContacts(
                matching: .init(value: true),
                keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactThumbnailImageDataKey,
                    CNContactDatesKey] as [CNKeyDescriptor]
                )
        else { return }
        print("Received contacts:", fetchedContacts)
        self._contactsPublisher.send(fetchedContacts.map(Contact.init(from:)))
    }

    private func fetchABContacts() {
        switch ABAddressBookGetAuthorizationStatus() {
        case .authorized: self.processABContacts()
        case .denied, .restricted: print("Access to AddressBook is denied/restricted. Unable to load ABRecords.")
        case .notDetermined: self.requestAuthorization()
        default: break
        }
    }

    private func requestAuthorization() {
        let addressBook = ABAddressBookCreate().takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
            if success {
                self.processABContacts();
            }
            else {
                print("Unable to request access to Address Book.", error?.localizedDescription ?? "Unknown error.")
            }
        })
    }

    private func processABContacts() {
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBook? = extractABAddressBookRef(abRef: ABAddressBookCreateWithOptions(nil, &errorRef))

        var abContacts: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()

        let contacts: [Contactable] = abContacts.compactMap { record in
            
            let abRecord = record as ABRecord
            let recordID = Int(getID(for: abRecord))

            guard
                let firstName = get(property: kABPersonFirstNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let middleName = get(property: kABPersonMiddleNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let lastName = get(property: kABPersonLastNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let creationDate = get(property: kABPersonCreationDateProperty, fromRecord: abRecord, castedAs: NSDate.self, returnedAs: Date.self)
            else { return nil }

            let email =  get(property: kABPersonEmailProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self)
            let phoneNumbers = getPhoneNumbers(fromRecord: abRecord)
            let thumbnailImage = get(imageOfSize: .thumbnail, from: abRecord)?.uiImage
            let fullImage = get(imageOfSize: .full, from: abRecord)?.uiImage
            return Contact(
                id: recordID.description,
                name: [firstName, middleName, lastName].compactMap { $0 }.joined(separator: " "),
                phoneNumber: phoneNumbers.first,
                email: email,
                thumbnailImage: thumbnailImage,
                note: "",
                createDate: creationDate
            )
        }

        DispatchQueue.main.async {
            self.objectWillChange.send()
            self._contactsPublisher.send(contacts)
        }

    }

    private func get<T, X>(property: ABPropertyID, fromRecord record: ABRecord, castedAs: T.Type, returnedAs: X.Type) -> X? {
        (ABRecordCopyValue(record, property).takeRetainedValue() as? T) as? X
    }

    private func getID(for record: ABRecord) -> ABRecordID {
        ABRecordGetRecordID(record)
    }

    private func getPhoneNumbers(
        fromRecord record: ABRecord
    ) -> [PhoneNumber] {
        guard
            let abPhoneNumbers: ABMultiValue = ABRecordCopyValue(record, kABPersonPhoneProperty)?.takeRetainedValue()
        else { return [] }

        var phoneNumbers: [PhoneNumber] = []
        for index in 0..<ABMultiValueGetCount(abPhoneNumbers) {
            let phoneLabel = ABMultiValueCopyLabelAtIndex(abPhoneNumbers, index)?.takeRetainedValue()
            let localizedPhoneLabel = localized(phoneLabel: phoneLabel)
            guard
                let abPhoneNumber = ABMultiValueCopyValueAtIndex(abPhoneNumbers, index)?.takeRetainedValue() as? String,
                let phoneNumber = PhoneNumber(from: abPhoneNumber, withLabel: localizedPhoneLabel)
            else { continue }
            phoneNumbers.append(phoneNumber)
        }

        return phoneNumbers
    }

    private func get(
        imageOfSize imageFormat: Contact.ImageFormat,
        from record: ABRecord
    ) -> Data? {

        guard ABPersonHasImageData(record) else { return nil }

        let abImageFormat: ABPersonImageFormat = {
            switch imageFormat {
            case .full: return kABPersonImageFormatOriginalSize
            case .thumbnail: return kABPersonImageFormatThumbnail
            }
        }()

        return ABPersonCopyImageDataWithFormat(record, abImageFormat).takeRetainedValue() as Data
    }

    private func getCreationDate(from abRecord: ABRecord) -> Date? {
        let object = ABRecordCopyValue(abRecord, kABPersonCreationDateProperty).takeRetainedValue() as! NSDate
        return object as Date
    }

    private func processAddressbookRecord(addressBookRecord: ABRecord) {
        var contactName: String = (ABRecordCopyCompositeName(addressBookRecord).takeRetainedValue() as NSString) as String
        NSLog("contactName: \(contactName)")
        processEmail(addressBookRecord: addressBookRecord)
    }

    private func processEmail(addressBookRecord: ABRecord) {
        let emailArray:ABMultiValue = extractABEmailRef(abEmailRef: ABRecordCopyValue(addressBookRecord, kABPersonEmailProperty))!
        for index in 0..<ABMultiValueGetCount(emailArray)  {
            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, index)
            var myString = extractABEmailAddress(abEmailAddress: emailAdd)
            print("email: \(myString!)")
        }
    }

    private func extractABAddressBookRef(abRef: Unmanaged<ABAddressBook>!) -> ABAddressBook? {
        guard let ab = abRef else { return nil }
        return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
    }

    private func extractABEmailRef (abEmailRef: Unmanaged<ABMultiValue>!) -> ABMultiValue? {
        guard let ab = abEmailRef else { return nil }
        return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
    }

    private func extractABEmailAddress (abEmailAddress: Unmanaged<AnyObject>!) -> String? {
        guard let ab = abEmailAddress else { return nil }
        return Unmanaged.fromOpaque(ab.toOpaque()).takeUnretainedValue() as CFString as String
    }

    private func localized(phoneLabel: CFString?) -> String? {
        guard let phoneLabel = phoneLabel else {
            return nil
        }
        
        if CFStringCompare(phoneLabel, kABHomeLabel, []) == .compareEqualTo {            // use `[]` for options in Swift 2.0
            return "Home"
        } else if CFStringCompare(phoneLabel, kABWorkLabel, []) == .compareEqualTo {
            return "Work"
        } else if CFStringCompare(phoneLabel, kABOtherLabel, []) == .compareEqualTo {
            return "Other"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneMobileLabel, []) == .compareEqualTo {
            return "Mobile"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneIPhoneLabel, []) == .compareEqualTo {
            return "iPhone"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneMainLabel, []) == .compareEqualTo {
            return "Main"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneHomeFAXLabel, []) == .compareEqualTo {
            return "Home fax"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneWorkFAXLabel, []) == .compareEqualTo {
            return "Work fax"
        } else if CFStringCompare(phoneLabel, kABPersonPhoneOtherFAXLabel, []) == .compareEqualTo {
            return "Other fax"
        } else if CFStringCompare(phoneLabel, kABPersonPhonePagerLabel, []) == .compareEqualTo {
            return "Pager"
        } else {
            return phoneLabel as String
        }
    }

}

// MARK: - Sort Logic Extension
extension ContactsInteractor {
    public enum SortType {
        case creationDate
        case name
        case followUps
    }
}

extension Collection {
    func sorted<Value>(by keyPath: KeyPath<Element, Value>) -> [Element] where Value: Comparable {
        self.sorted(by: { firstElement, secondElement in
            firstElement[keyPath: keyPath] < secondElement[keyPath: keyPath]
        })
    }
}
