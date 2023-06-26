//
//  ConditionalLazyVStack.swift
//  FollowUp
//
//  Created by Aaron Baw on 18/06/2023.
//

import SwiftUI

struct ConditionalLazyVStack<Content: View>: View {
    var lazy: Bool
    var content: () -> Content
    var body: some View {
        if lazy {
            LazyVStack { content() }
        } else {
            VStack { content() }
        }
    }
}

struct ConditionalLazyVStack_Previews: PreviewProvider {
    static var previews: some View {
        ConditionalLazyVStack(lazy: true, content: {
            Text("Something")
        })
    }
}
