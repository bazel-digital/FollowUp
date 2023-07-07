//
//  TagsCarouselView.swift
//  FollowUp
//
//  Created by Aaron Baw on 14/06/2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct TagsCarouselView: View {
    
    var contact: any Contactable
    
    @State private var tags: [Tag]
    @State var creatingTag: Bool = false
    @State var draggingTag: Tag?
    @FocusState var textFieldIsFocused: Bool
    @State var newTagTitle: String = ""
    
    @EnvironmentObject var followUpManager: FollowUpManager
    
    // MARK: - Init
    init(
        contact: any Contactable
    ) {
        self.contact = contact
        self._tags = .init(initialValue: Array(contact.tags))
    }
    
    // MARK: - Computed Properties
    var tagSearchSuggestions: [Tag] {
        self.followUpManager.store.tagSuggestions.filter { tagSuggestion in
            !self.tags.contains(where: { $0.isEqual(tagSuggestion)
            })
        }
    }
    
    // MARK: - Views
    private var addTagButton: some View {
        Button(action: {
            self.showTextField()
        }, label: {
            Text("+")
        })
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, Constant.Tag.horiztontalPadding)
        .padding(.vertical, Constant.Tag.verticalPadding)
        .background(Color(.systemGray3))
        .cornerRadius(Constant.Tag.cornerRadius)
    }
    
    private var suggestedTagView: some View {
        HStack {
            CloseButton(onClose: { self.hideTextField() })
            ScrollView(.horizontal) {
                HStack {
                    ForEach(tagSearchSuggestions) { suggestedTag in
                        TagChipView(tag: suggestedTag, action: { self.onTapTagSuggestion(suggestedTag) })
                            .transition(.push(from: .trailing))
                    }
                }
            }
        }
        .animation(.default, value: tagSearchSuggestions)
    }
    
    private var creatingTagView: some View {
            TextField(text: $newTagTitle, label: {
                Text(.newTag)
            })
            .textFieldStyle(.roundedBorder)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    suggestedTagView
                })
            }
            .onChange(of: newTagTitle, perform: { tagSearchQuery in
                followUpManager.store.set(tagSearchQuery:tagSearchQuery)
            })
            .padding(.vertical, Constant.Tag.verticalPadding)
            .focused($textFieldIsFocused)
            .onSubmit(onCreateTagSubmit)
            .submitLabel(.go)
        }
        
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(tags) { tag in
                    TagChipView(tag: tag, action: { changeTagColour(tag: tag) })
                        .onDrag {
                            self.draggingTag = tag
                            return NSItemProvider(object: String(tag.id) as NSString) // Use the `id` or unique identifier of your `Tag`
                        }
                        .onDrop(
                            of: [.plainText],
                            delegate:
                                DragRelocateDelegate(
                                    item: tag,
                                    localTags: $tags,
                                    currentlyDraggedItem: $draggingTag,
                                    commitTagChangesClosure: commitTagChanges
                                )
                        )
                        .transition(.opacity)
                        .contextMenu {
                            Button(
                                role: .destructive,
                                action: {
                                    delete(tag: tag)
                                },
                                label: { Label(title: { Text(.delete) }, icon: { Image(icon: .trash) })
                            })
                        }
                }
                
                if creatingTag {
                    creatingTagView
                }
                
                addTagButton
            }
            .animation(.default, value: tags)
            .padding()
            .animation(.default, value: creatingTag)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Methods
    func commitTagChanges() {
        followUpManager.contactsInteractor.set(tags: tags, for: contact)
    }
    
    private func showTextField() {
        self.creatingTag = true
        self.textFieldIsFocused = true
    }
    
    private func hideTextField() {
        self.newTagTitle = ""
        self.creatingTag = false
        self.textFieldIsFocused = false
    }
    
    private func onTapTagSuggestion(_ tag: Tag) {
        withAnimation {
            tags.append(tag)
        }
        self.hideTextField()
        self.followUpManager.contactsInteractor.set(tags: tags, for: contact)
    }
    
    private func onCreateTagSubmit() {
        if !self.newTagTitle.isEmpty {
            
            // If the first suggested tag contains the same title, use that instead.
            let tag: Tag = (newTagTitle == tagSearchSuggestions.first?.title) ? tagSearchSuggestions.first! : .init(title: newTagTitle)
            
            // Add the new tag to the list of tags.
            withAnimation {
                tags.append(tag)
            }
        }
        
        self.hideTextField()
        self.followUpManager.contactsInteractor.set(tags: tags, for: contact)
    }
    
    func delete(tag: Tag) {
        self.tags.removeAll(where: { $0 == tag })
        self.followUpManager.contactsInteractor.remove(tag: tag, from: contact)
    }
    
    func changeTagColour(tag: Tag) {
        withAnimation {
            self.followUpManager.contactsInteractor.changeColour(forTag: tag, toColour: .random(), forContact: contact)
        }
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: Tag
    @Binding var localTags: [Tag]
    @Binding var currentlyDraggedItem: Tag?
    var commitTagChangesClosure: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard item != currentlyDraggedItem,
              let currentlyDraggedItem = currentlyDraggedItem,
              let fromIndex = localTags.firstIndex(where: { $0.id == currentlyDraggedItem.id }),
              let toIndex = localTags.firstIndex(where: { $0.id == item.id }),
              fromIndex != toIndex
        else { return }
        
        withAnimation {
            localTags.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        currentlyDraggedItem = nil
        commitTagChangesClosure()
        return true
    }
}

struct TagsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        TagsCarouselView(contact: Contact.mocked)
    }
}
