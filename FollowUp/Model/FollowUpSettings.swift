//
//  FollowUpSettings.swift
//  FollowUp
//
//  Created by Aaron Baw on 23/01/2023.
//

import Foundation
import RealmSwift

class FollowUpSettings: Object {
    @Persisted var dailyFollowUpGoal: Int? = 10
        
    @Persisted var conversationStarters: RealmSwift.List<ConversationStarterTemplate>
    
    // MARK: - Methods
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
                self.conversationStarters.append(.init(template: "Conversation Starter", platform: .whatsApp))
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
    
    public func removeConversationStareters(atOffsets offsets: IndexSet) {
        do {
            try self.realm?.write {
                self.conversationStarters.remove(atOffsets: offsets)
            }
        } catch {
            assertionFailurePreviewSafe("Could not remove conversation stareters. \(error.localizedDescription)")
        }
    }
    
}
