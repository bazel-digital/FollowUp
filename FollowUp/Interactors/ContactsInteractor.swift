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

protocol ContactsInteracting {
    var contacts: [Contact] { get }
    var contactsPublisher: Published<[Contact]>.Publisher { get }
    func fetchContacts() async
}

class ContactsInteractor: ContactsInteracting, ObservableObject {

    // MARK: - Public Properties
    @Published var contacts: [Contact] = []

    var contactsPublisher: Published<[Contact]>.Publisher {
        self.$contacts
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
        self.contacts = fetchedContacts.map(RecentContact.init(from:))
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

        let contacts: [Contact] = abContacts.compactMap { record in
            
            let abRecord = record as ABRecord
            let recordID = getID(for: abRecord)

            guard
                let firstName = get(property: kABPersonFirstNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let middleName = get(property: kABPersonMiddleNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let lastName = get(property: kABPersonLastNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let creationDate = get(property: kABPersonCreationDateProperty, fromRecord: abRecord, castedAs: NSDate.self, returnedAs: Date.self)
            else { return nil }

            let email =  get(property: kABPersonEmailProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self)
            let phoneNumberString = get(property: kABPersonPhoneProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self)
            let phoneNumber = PhoneNumber(from: phoneNumberString ?? "")
            let thumbnailImage = get(imageOfSize: .thumbnail, from: abRecord)?.uiImage
            let fullImage = get(imageOfSize: .full, from: abRecord)?.uiImage
            
            return RecentContact(
                id: recordID.description,
                name: [firstName, middleName, lastName].compactMap { $0 }.joined(separator: " "),
                phoneNumber: phoneNumber,
                email: email,
                thumbnailImage: thumbnailImage,
                note: "",
                createDate: creationDate
            )
        }

        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.contacts = contacts
        }

    }

    private func get<T, X>(property: ABPropertyID, fromRecord record: ABRecord, castedAs: T.Type, returnedAs: X.Type) -> X? {
        (ABRecordCopyValue(record, property).takeRetainedValue() as? T) as? X
    }

    private func getID(for record: ABRecord) -> ABRecordID {
        ABRecordGetRecordID(record)
    }

    private func get(
        imageOfSize imageFormat: RecentContact.ImageFormat,
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
        return Unmanaged.fromOpaque(abEmailAddress.toOpaque()).takeUnretainedValue() as CFString as String
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

extension Sequence {
    func sorted<Value>(by keyPath: KeyPath<Element, Value>) -> [Element] where Value: Comparable {
        self.sorted(by: { firstElement, secondElement in
            firstElement[keyPath: keyPath] < secondElement[keyPath: keyPath]
        })
    }
}
