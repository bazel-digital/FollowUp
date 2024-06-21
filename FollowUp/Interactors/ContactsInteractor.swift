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
    var contactsPublisher: AnyPublisher<[any Contactable], FollowUpError> { get }
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

    // MARK: - Static Properties
    public static var shared: ContactsInteracting = ContactsInteractor()

    // MARK: - Private Properties
    private var _contactsPublisher: PassthroughSubject<[any Contactable], FollowUpError> = .init()
    private var realm: Realm?
    private let backgroundQueue: DispatchQueue = .init(label: "com.bazel.followup.contacts.background", qos: .background)

    // MARK: - Public Properties
    var contactsPublisher: AnyPublisher<[any Contactable], FollowUpError> { _contactsPublisher.eraseToAnyPublisher() }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { self.$contactSheet.eraseToAnyPublisher() }
    
    var statePublisher: AnyPublisher<ContactInteractorState, Never> { self.$state.eraseToAnyPublisher() }

    @Published var contactSheet: ContactSheet?
    @Published var contactsAuthorized: Bool = false
    @Published var state: ContactInteractorState = .fetchingContacts
    
    // MARK: - Initialiser
    init(realm: Realm?) {
        self.realm = realm
    }

    var contactSheetPublisher: AnyPublisher<ContactSheet?, Never> { self.$contactSheet.eraseToAnyPublisher() }

    @Published var contactSheet: ContactSheet?

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
            
            self.removeIfOrphaned(tag: tag)
            
        }
    }
    
    /// Checks if the tag is orphaned, and if so, removes it.
    private func removeIfOrphaned(tag: Tag) {
        guard tag.taggedContacts.isEmpty else { return }
        Log.info("Tag: \(tag.title) no longer belongs to any contacts. Removing now.")
        self.writeToRealm { realm in
            realm.delete(tag)
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
            self.fetchABContacts { abContactResult in
                
                switch abContactResult {

                case let .failure(error):
                    self._contactsPublisher.send(completion: .failure(error))
                    return
                    
                case let .success(abContacts):
                    self.fetchCNContacts { cnContactResult in
                        
                        switch cnContactResult {
                        case let .failure(error):
                            self._contactsPublisher.send(completion: .failure(error))
                        case let .success(cnContacts):
                            let mergedContacts = self.merged(
                                cnContacts: cnContacts.map(
                                    Contact.init(from:)
                                ),
                                withABContacts: abContacts
                            )
                            
                            DispatchQueue.main.async {
                                #if DEBUG || TESTING
                                    print(mergedContacts)
                                #endif
                                self._contactsPublisher.send(mergedContacts)
                                self.objectWillChange.send()
                            }
                        }
                    }
                }
            }
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
    
    private func fetchCNContacts(completion: ((Result<[CNContact], FollowUpError>) -> Void)? = nil) {
        Log.info("Fetching CNContacts.")
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { authorizationResult, error in
            if let error = error {
                Log.error("Error fetching CNContacts: \(error.localizedDescription)")
                completion?(.failure(.requestAccessError(error)))
            }
            
            self.contactsAuthorized = authorizationResult
            
            do {
                let fetchedContacts = try contactStore.unifiedContacts(
                    matching: .init(value: true),
                    keysToFetch: [
                        CNContactGivenNameKey,
                        CNContactDatesKey,
                        CNContactPhoneNumbersKey,
                        CNContactFamilyNameKey,
                        CNContactMiddleNameKey,
                        CNContactImageDataKey,
                        CNContactThumbnailImageDataKey,
                        CNContactNoteKey,
                        CNContactDatesKey
                    ] as [CNKeyDescriptor]
                )
                Log.info("Received CNContacts: \(fetchedContacts.count)")
                completion?(.success(fetchedContacts))
            } catch {
                Log.error("Unable to fetch CNContacts: \(error.localizedDescription)")
                completion?(.failure(.cnContactQueryError(error)))
            }
        }
    }

    private func fetchABContacts(completion: @escaping (Result<[any Contactable], FollowUpError>) -> Void) {
        Log.info("Fetching ABContacts.")
        switch ABAddressBookGetAuthorizationStatus() {
        case .authorized: self.processABContacts(completion: completion)
        case .denied, .restricted:
            self.contactsAuthorized = false
            self.setState(.authorizationDenied)
        case .notDetermined: self.requestAuthorization(completion: completion)
        default: break
        }
    }
    
    /// Merges contacts from the CNContact and AddressBook frameworks, so as to keep the 'note' as well as 'creationDate' properties.
    private func merged(cnContacts: [any Contactable], withABContacts abContacts: [any Contactable]) -> [any Contactable] {
        var dictionary: [Int: any Contactable] = [:]
        cnContacts.forEach { contact in dictionary[contact.mergeableHashValue()] = contact }
        abContacts.forEach { contact in
            dictionary[contact.mergeableHashValue(), default: contact].createDate = contact.createDate
        }
        return Array(dictionary.values)
    }

    private func requestAuthorization(completion: @escaping (Result<[any Contactable], FollowUpError>) -> Void) {
        self.setState(.requestingAuthorization)
        let addressBook = ABAddressBookCreate().takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
            if success {
                self.contactsAuthorized = success
                self.processABContacts(completion: completion)
            }
            else {
                Log.error("Unable to request access to Address Book \(error?.localizedDescription ?? "Unknown error.")")
                if let error = error {
                    completion(.failure(.requestAccessError(error)))
                }
            }
        })
    }

    private func processABContacts(completion: (Result<[any Contactable], FollowUpError>) -> Void) {
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
            else {
                Log.warn("Unable to retrieve contact details for Contact with record ID: \(recordID).")
                return nil
            }
            
            let email =  get(property: kABPersonEmailProperty, fromRecord: abRecord, castedAs: NSString.self, returnedAs: String.self)
            let phoneNumbers = getPhoneNumbers(fromRecord: abRecord)
            let thumbnailImage = get(imageOfSize: .thumbnail, from: abRecord)?.uiImage
            let fullImage = get(imageOfSize: .full, from: abRecord)?.uiImage
            return Contact(
                contactID: recordID.description,
                name: self.generateNameString(forFirstName: firstName, middleName: middleName, lastName: lastName),
                phoneNumber: phoneNumbers.first,
                email: email,
                thumbnailImage: thumbnailImage,
                note: nil,
                createDate: creationDate
            )
        }
        
        completion(.success(contacts))

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
    
    private func generateNameString(forFirstName firstName: String, middleName: String, lastName: String) -> String {
        [firstName, middleName.isEmpty ? nil : middleName, lastName].compactMap { $0 }.joined(separator: " ")
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
