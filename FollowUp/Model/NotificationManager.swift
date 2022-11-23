//
//  NotificationManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/11/2022.
//

import Foundation
import NotificationCenter

protocol NotificationManaging {
    func scheduleNotification(
        forNumberOfAddedContacts numberOfAddedContacts: Int,
        withConfiguration configuration: NotificationConfiguration
    )
    func requestNotificationAuthorization(completion: @escaping () -> Void)
}

extension NotificationManaging {
    func requestNotificationAuthorization(){
        self.requestNotificationAuthorization { }
    }
}

class NotificationManager: NotificationManaging {
    
    let configuration: NotificationConfiguration
    
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
            print("Start Up | \(success ? "Successfully" : "Unsuccessfully") granted notification authorization.")
            if let error = error {
                print("Start Up | Error requesting notification authorization: \(error.localizedDescription)")
            }
            completion()
        })
    }
}

/// Stores trigger information as well as frequency for notifications.
struct NotificationConfiguration {
    
    enum Trigger {
        // TODO: Implement location-based notification triggers.
//        case arrivingAtLocation
        case specificTime(DateComponents)
        case now

        var unNotificationTrigger: UNNotificationTrigger {
            switch self {
            case let .specificTime(dateComponents):
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            case .now:
                return UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
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
