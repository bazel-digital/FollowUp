//
//  FollowUpSettings.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import Foundation
import RealmSwift

class FollowUpSettings: Object {
    
    // MARK: - Stored Properties
    @Persisted var dailyFollowUpGoal: Int? = 10
    @Persisted var conversationStarters: RealmSwift.List<ConversationStarterTemplate>
    @Persisted var contactListGrouping: ContactListGrouping = .dayMonthYear
    @Persisted var followUpRemindersActive: Bool = false
    @UserDefaultsPersisted(Constant.Secrets.openAIUserDefaultsKey) var openAIKey: String = ""
    
}

extension FollowUpSettings {
    // MARK: - Enums
    enum ContactListGrouping: String, PersistableEnum, CaseIterable {
        case dayMonthYear
        case monthYear
        case relative
        
        var keyPath: KeyPath<any Contactable, Grouping> {
            switch self {
            case .dayMonthYear: return \.dayMonthYearDateGrouping
            case .monthYear: return \.monthYearDateGrouping
            case .relative: return \.newOrRelativeDateGrouping
            }
        }
        
        var title: String {
            switch self {
            case .dayMonthYear: return "Day, Month, Year"
            case .monthYear: return "Month, Year"
            case .relative: return "Relative"
            }
        }
    }
}
 
extension FollowUpSettings {
    
    // MARK: - Methods
    func set(contactListGrouping: ContactListGrouping) {
        self.update {
            self.contactListGrouping = contactListGrouping
        }
    }
    
    func update(conversationStarter updatedConversationStarter: ConversationStarterTemplate) {
        
        guard let index = self.conversationStarters.firstIndex(where: {
            $0.id == updatedConversationStarter.id
        }) else {
            assertionFailurePreviewSafe("Could not find index to update conversation starter for id: \(updatedConversationStarter.id)")
            return
        }
        do{
            try self.realm?.write {
                self.conversationStarters.replace(index: index, object: updatedConversationStarter)
            }
        } catch {
            assertionFailurePreviewSafe("Could not update conversation starter with id: \(updatedConversationStarter.id). \(error.localizedDescription)")
        }
    }
    
    func set(dailyFollowUpGoal: Int) {
        do {
            try self.realm?.write {
                self.dailyFollowUpGoal = dailyFollowUpGoal
            }
        } catch {
            assertionFailurePreviewSafe("Could not set dailyFollowUpGoal. \(error.localizedDescription)")
        }
    }
    
    func addNewConversationStarter() {
        do {
            try self.realm?.write {
                if var randomStarter = ConversationStarterTemplate.examples.randomElement() {
                    randomStarter.id = UUID().uuidString
                    self.conversationStarters.append(randomStarter)
                }
            }
        } catch {
            assertionFailurePreviewSafe("Could not add conversation starter. \(error.localizedDescription)")
        }
    }
    
    public func moveConversationStarters(fromOffsets offsets: IndexSet, toOffset destination: Int) {
        do {
            try self.realm?.write {
                self.conversationStarters.move(fromOffsets: offsets, toOffset: destination)
            }
        } catch {
            assertionFailurePreviewSafe("Could not move conversation stareters. \(error.localizedDescription)")
        }
    }
    
    public func removeConversationStarters(atOffsets offsets: IndexSet) {
        do {
            try self.realm?.write {
                self.conversationStarters.remove(atOffsets: offsets)
            }
        } catch {
            assertionFailurePreviewSafe("Could not remove conversation starters. \(error.localizedDescription)")
        }
    }

    public func set(openAIKey: String) {
        self.update {
            self.openAIKey = openAIKey
        }
    }
    
    public func set(followUpRemindersActive: Bool) {
        self.update {
            self.followUpRemindersActive = followUpRemindersActive
        }
    }
    
    private func update(closure: @escaping () -> Void, errorMessage: String = "Could not perform update") {
        do {
            try self.realm?.write {
                closure()
            }
        } catch {
            assertionFailurePreviewSafe("\(errorMessage) \(error.localizedDescription)")
        }
    }
    
}
