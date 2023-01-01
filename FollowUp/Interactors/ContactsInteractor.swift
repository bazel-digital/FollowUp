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
import RealmSwift
import SwiftUI
import Fakery

// MARK: - Typealiases
typealias ContactID = String

// MARK: -
protocol ContactsInteracting {
    var contactsPublisher: AnyPublisher<[any Contactable], Never> { get }
    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { get }
    var statePublisher: AnyPublisher<ContactInteractorState, Never> { get }
    var contactSheet: ContactSheet? { get }
    func fetchContacts()
    
    // MARK: - Actions
    func highlight(_ contact: any Contactable)
    func unhighlight(_ contact: any Contactable)
    func addToFollowUps(_ contact: any Contactable)
    func removeFromFollowUps(_ contact: any Contactable)
    func markAsFollowedUp(_ contact: any Contactable)
    
    // MARK: - Actions (Sheet)
    func displayContactSheet(_ contact: any Contactable)
    func hideContactSheet()
    func dismiss(_ contact: any Contactable)
    
    // MARK: - Actions (Tags)
    func add(tag: Tag, to contact: any Contactable)
    func remove(tag: Tag, from contact: any Contactable)
    func removeTags(forContact contact: any Contactable, atOffsets offsets: IndexSet)
    func moveTags(forContact contact: any Contactable, fromOffsets offsets: IndexSet, toOffset destination: Int)
    func set(tags: [Tag], for contact: any Contactable)
    func changeColour(forTag tag: Tag, toColour colour: Color, forContact contact: any Contactable)
}

/// Describes the current state of the contacts interactor.
enum ContactInteractorState {
    /// Currently awaiting authorization from the user to fetch contacts.
    case requestingAuthorization
    /// Authorization for reading contacts denied.
    case authorizationDenied
    /// Fetching contacts.
    case fetchingContacts
    /// Contacts have been loaded and are up to date.
    case loaded
}

// MARK: -
class ContactsInteractor: ContactsInteracting, ObservableObject {

    // MARK: - Private Properties
    private var _contactsPublisher: PassthroughSubject<[any Contactable], Never> = .init()
    private var realm: Realm?
    private let backgroundQueue: DispatchQueue = .init(label: "com.bazel.followup.background", qos: .background)

    // MARK: - Public Properties
    var contactsPublisher: AnyPublisher<[any Contactable], Never> { _contactsPublisher.eraseToAnyPublisher() }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { self.$contactSheet.eraseToAnyPublisher() }
    
    var statePublisher: AnyPublisher<ContactInteractorState, Never> { self.$state.eraseToAnyPublisher() }

    @Published var contactSheet: ContactSheet?
    @Published var contactsAuthorized: Bool = false
    @Published var state: ContactInteractorState = .fetchingContacts
    
    // MARK: - Initialiser
    init(realm: Realm?) {
        self.realm = realm
    }

    // MARK: - Public Methods
    
    func highlight(_ contact: any Contactable) {
        self.modify(contact: contact, closure: {
            $0?.highlighted = true
        })
    }

    func unhighlight(_ contact: any Contactable) {
        self.modify(contact: contact, closure: {
            $0?.highlighted = false
        })
    }
    
    func addToFollowUps(_ contact: any Contactable) {
        self.modify(contact: contact, closure: {
            $0?.containedInFollowUps = true
        })
    }

    func removeFromFollowUps(_ contact: any Contactable) {
        self.modify(contact: contact, closure: {
            $0?.containedInFollowUps = false
        })
    }

    func markAsFollowedUp(_ contact: any Contactable) {
        self.modify(contact: contact) { contact in
            contact?.followUps += 1
        }
    }

    func displayContactSheet(_ contact: any Contactable) {
        self.contactSheet = contact.sheet
    }

    func hideContactSheet() {
        self.contactSheet = nil
    }

    func dismiss(_ contact: any Contactable) {
        self.modify(contact: contact, closure: {
            $0?.lastInteractedWith = .now
        })
    }
    
    // MARK: - Actions (Tags)
    func add(tag: Tag, to contact: any Contactable) {
        self.modify(contact: contact){ contact in
            contact?.tags.append(tag)
        }
    }
    
    func set(tags: [Tag], for contact: any Contactable) {
        self.modify(contact: contact) { contact in
            contact?.tags = .init()
            contact?.tags.append(objectsIn: tags)
        }
    }
    
    func remove(tag: Tag, from contact: any Contactable) {
        self.modify(contact: contact) { contact in
            guard let tagIndex = contact?.tags.map(\.id).firstIndex(of: tag.id)
            else {
                Log.warn("Attempted to remove tag: \(tag) from \(contact?.name ?? "Unknown contact")(\(contact?.id ?? "") but could not find an index for it in the current list of tags.")
                return
            }
            contact?.tags.remove(at: tagIndex)
        }
    }
    
    public func removeTags(forContact contact: any Contactable, atOffsets offsets: IndexSet) {
        self.modify(contact: contact) { contact in
            contact?.tags.remove(atOffsets: offsets)
        }
    }
    
    public func moveTags(forContact contact: any Contactable, fromOffsets offsets: IndexSet, toOffset destination: Int) {
        self.modify(contact: contact) { contact in
            contact?.tags.move(fromOffsets: offsets, toOffset: destination)
        }
    }
    
    func changeColour(forTag tag: Tag, toColour colour: Color, forContact contact: any Contactable) {
        self.writeToRealm { _ in
            tag.colour = colour
        }
    }
    
    // MARK: - Private methods
    private func modify(contact: any Contactable, closure: @escaping (Contact?) -> Void) {
        writeToRealm { realm in
            let contact = realm.object(ofType: Contact.self, forPrimaryKey: contact.id)
            closure(contact)
        }
    }
    
    private func writeToRealm(_ closure: @escaping (Realm) -> Void) {
        guard let realm = self.realm else {
            Log.error("Unable to modify contact, as no realm instance was found in the ContactsInteractor.")
            return
        }

        do {
            try realm.writeAsync {
                closure(realm)
            }
        } catch {
            Log.error("Could not perform action: \(error.localizedDescription)")
        }
    }
}

// MARK: - Fetch Logic Extension
extension ContactsInteractor {
    
    // MARK: - Public Methods
    public func fetchContacts() {
        self.backgroundQueue.async {
            self.fetchABContacts()
        }
    }
    
    // MARK: - Private Methods
    private func setState(_ state: ContactInteractorState) {
        if Thread.isMainThread {
            self.state = state
        } else {
            DispatchQueue.main.async {
                self.state = state
            }
        }
    }

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
    
    private func fetchCNContacts(completion: @escaping () -> Void? = {()}) {
        print("Fetching contacts.")
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { authorizationResult, error in
            if let error = error {
                print("Error fetching contacts: \(error.localizedDescription)")
            }
            
            self.contactsAuthorized = authorizationResult
            
            guard let fetchedContacts = try? contactStore.unifiedContacts(
                matching: .init(value: true),
                keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactThumbnailImageDataKey,
                    CNContactDatesKey] as [CNKeyDescriptor]
            ) else {
                return
            }
            print("Received contacts:", fetchedContacts)
            self._contactsPublisher.send(fetchedContacts.map(Contact.init(from:)))
        }
    }

    private func fetchABContacts() {
        switch ABAddressBookGetAuthorizationStatus() {
        case .authorized: self.processABContacts()
        case .denied, .restricted:
            self.contactsAuthorized = false
            self.setState(.authorizationDenied)
        case .notDetermined: self.requestAuthorization()
        default: break
        }
    }

    private func requestAuthorization() {
        self.setState(.requestingAuthorization)
        let addressBook = ABAddressBookCreate().takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
            if success {
                self.contactsAuthorized = success
                self.processABContacts();
            }
            else {
                print("Unable to request access to Address Book.", error?.localizedDescription ?? "Unknown error.")
            }
        })
    }

    private func processABContacts() {
        self.setState(.fetchingContacts)
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBook? = extractABAddressBookRef(abRef: ABAddressBookCreateWithOptions(nil, &errorRef))

        var abContacts: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()

        let contacts: [any Contactable] = abContacts.compactMap { record in
            
            let abRecord = record as ABRecord
            let recordID = Int(getID(for: abRecord))

            guard
                let firstName = get(property: kABPersonFirstNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let middleName = get(property: kABPersonMiddleNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let lastName = get(property: kABPersonLastNameProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self),
                let creationDate = get(property: kABPersonCreationDateProperty, fromRecord: abRecord, castedAs: NSDate.self, returnedAs: Date.self)
                    // TODO: CHANGE!
            else { return Contact.mocked }

            let email =  get(property: kABPersonEmailProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self)
            let phoneNumbers = getPhoneNumbers(fromRecord: abRecord)
            let thumbnailImage = get(imageOfSize: .thumbnail, from: abRecord)?.uiImage
            let fullImage = get(imageOfSize: .full, from: abRecord)?.uiImage
            return Contact(
                contactID: recordID.description,
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
            self.setState(.loaded)
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
