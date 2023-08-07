//
//  NotificationManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/11/2022.
//

import Foundation
import NotificationCenter
import RealmSwift

protocol NotificationManaging {
    func scheduleNotification(
        forNumberOfAddedContacts numberOfAddedContacts: Int,
        withConfiguration configuration: NotificationConfiguration
    )
    func requestNotificationAuthorization(completion: @escaping () -> Void)
    func clearScheduledNotifications()
}

extension NotificationManaging {
    func requestNotificationAuthorization(){
        self.requestNotificationAuthorization { }
    }
}

class NotificationManager: NotificationManaging {
    
    
    let configuration: NotificationConfiguration
    
    // MARK: - Static Properties
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    // MARK: - Initializer
    init(configuration: NotificationConfiguration = .default) {
        // TODO: Allow this to be configurable by the user.
        self.configuration = configuration
    }
    
    func scheduleNotification(
        forNumberOfAddedContacts numberOfAddedContacts: Int,
        withConfiguration configuration: NotificationConfiguration
    ) {
        self.requestNotificationAuthorization {
            let notification = UNMutableNotificationContent()
            notification.title = Localizer.Notification.title
            notification.body = Localizer.Notification.body(withNumberOfPeople: numberOfAddedContacts, withinTimeFrame: .today)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: notification,
                trigger: configuration.trigger.unNotificationTrigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func requestNotificationAuthorization(completion: @escaping () -> Void){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {
            success, error in
            Log.info("Start Up | \(success ? "Successfully" : "Unsuccessfully") granted notification authorization.")
            if let error = error {
                Log.error("Start Up | Error requesting notification authorization: \(error.localizedDescription)")
            }
            completion()
        })
    }

    func clearScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

typealias NotificationTrigger = NotificationConfiguration.Trigger

/// Stores trigger information as well as frequency for notifications.
struct NotificationConfiguration {
    
    enum Trigger {
        // TODO: Implement location-based notification triggers.
        // TODO: Add user-configuration for notifications (e.g. custom time and frequency).
//        case arrivingAtLocation
        case specificTime(DateComponents)
        case now
        #if DEBUG
        case afterSeconds(Int)
        #endif

        var unNotificationTrigger: UNNotificationTrigger {
            switch self {
            case let .specificTime(dateComponents):
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            case .now:
                // Local Notifications do not support firing an instant notification, so we wait five seconds before firing.
                return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            #if DEBUG
            case let .afterSeconds(seconds):
                return UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            #endif
            }
        }
    }
    
    var trigger: Trigger

    // MARK: - Static Properties
    static var `default`: NotificationConfiguration = .init(
        trigger: .specificTime(
            .init(
                calendar: .current,
                hour: Constant.Notification.defaultNotificationTriggerHour
            )
        )
    )
    
}
