//
//  ActionButtonGridView.swift
//  FollowUp
//
//  Created by Aaron Baw on 29/06/2023.
//

import SwiftUI

struct ActionButtonGridView: View {
    
    var contact: any Contactable
    var background: Background = .material
    var buttonFont: Font = .caption
    @EnvironmentObject var followUpManager: FollowUpManager
    private let generator: UIImpactFeedbackGenerator = .init(style: .medium)
    
    
    // MARK: - Computed Properties
    var contactsInteractor: ContactsInteracting { followUpManager.contactsInteractor }
    
    // MARK: - Enums
    enum Background {
        case material
        case clear
    }
    
    // MARK: - Highlight Or Unhighlight Button
    private var highlightButton: some View {
        Button(action: {
            contactsInteractor
                .highlight(contact)
            self.generator.impactOccurred()
        }, label: {
            VStack {
                Image(icon: .star)
                Text("Highlight")
                    .font(buttonFont)
            }
        })
        .accentColor(.yellow)
    }

    private var unhighlightButton: some View {
        Button(action: {
            contactsInteractor
                .unhighlight(contact)
            self.generator.impactOccurred()
        }, label: {
            VStack {
                Image(icon: .slashedStar)
                Text("Unhighlight")
                    .font(buttonFont)
            }
        })
        .accentColor(.orange)
    }
    
    @ViewBuilder
    private var highlightOrUnhighlightButton: some View {
        if !contact.highlighted {
            highlightButton
        } else {
            unhighlightButton
        }
    }

    private var followedUpButton: some View {
        Button(action: {
            contactsInteractor
                .markAsFollowedUp(contact)
            self.generator.impactOccurred()
        }, label: {
            VStack {
                Image(icon: .thumbsUp)
                Text("I followed up")
                    .font(buttonFont)
            }
        })
        .accentColor(.green)
        .disabled(contact.hasBeenFollowedUpToday)
    }

    
    // MARK: - Add Or Remove From Follow Ups
    private var addToFollowUpsButton: some View {
        Button(action: {
            contactsInteractor
                .addToFollowUps(contact)
            self.generator.impactOccurred()
        }, label: {
            VStack {
                Image(icon: .plus)
                Text("Add to follow ups")
                    .font(buttonFont)
            }
        })
    }

    private var removeFromFollowUpsButton: some View {
        Button(action: {
            contactsInteractor
                .removeFromFollowUps(contact)
            self.generator.impactOccurred()
        }, label: {
            VStack {
                Image(icon: .minus)
                Text("Remove from follow ups")
                    .font(buttonFont)
            }
        })
    }
    
    @ViewBuilder
    private var addOrRemoveFromFollowUpsButton: some View {
        if !contact.containedInFollowUps {
            addToFollowUpsButton
        } else {
            removeFromFollowUpsButton
        }
    }
    
    private var content: some View {
        LazyVGrid(columns: [
            .init(), .init(), .init()
        ], alignment: .center, content: {
            
            Group {
                highlightOrUnhighlightButton
                addOrRemoveFromFollowUpsButton
                followedUpButton
            }.transition(.opacity)
            
        })
    }
    
    var body: some View {
        switch background {
        case .clear: content
        case .material:
            content
                .padding()
                .background(Material.ultraThickMaterial)
                .cornerRadius(Constant.cornerRadius)
        }
    }
}

struct ActionButtonGridView_Previews: PreviewProvider {
    static var previews: some View {
        ActionButtonGridView(contact: .mocked)
            .environmentObject(FollowUpManager())
    }
}
