//
//  ContactNoteView.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/03/2023.
//

import SwiftUI

struct ContactNoteView: View {

    var note: String
    
    // MARK: - Private Stored Properties
    @State private var expanded: Bool = false

    var body: some View {
        VStack {
            Text("\(Image(icon: .personWithDescription)) \(note)")
                .fontWeight(.medium)
                .font(.body)
        }
        .padding()
        .background(Material.ultraThickMaterial)
        .cornerRadius(Constant.cornerRadius)
        .padding()
        .frame(maxHeight: expanded ? .infinity : Constant.ContactSheet.noteViewMaxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
    }
}

struct ContactNoteView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactNoteView(note: "This is just a test note, I don't mean anything by it. It is very longso bear in mind htat we need ot test it for ")
                .preferredColorScheme(.light)
            
            ContactNoteView(note: "This is just a test note, I don't mean anything by it.")
                .preferredColorScheme(.dark)
        }.previewLayout(.sizeThatFits)
    }
}
