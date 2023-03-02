//
//  ContactNoteView.swift
//  FollowUp
//
//  Created by Aaron Baw on 02/03/2023.
//

import SwiftUI

struct ContactNoteView: View {
    var note: String
    var body: some View {
        VStack {
            Text("\(Image(icon: .personWithDescription)) \(note)")
                .fontWeight(.medium)
                .font(.body)
        }.padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constant.cornerRadius)
    }
}

struct ContactNoteView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactNoteView(note: "This is just a test note, I don't mean anything by it.")
                .preferredColorScheme(.light)
            
            ContactNoteView(note: "This is just a test note, I don't mean anything by it.")
                .preferredColorScheme(.dark)
        }.previewLayout(.sizeThatFits)
    }
}
