//
//  IndividualFeatureView.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/02/2023.
//

import SwiftUI

struct IndividualFeatureView: View {
    
    var icon: Constant.Icon
    var title: String
    var description: String
    var colour: ColourOption
    
    enum ColourOption {
        case single(Color)
        case gradient([Color])
    }
    
    private var imageView: some View {
        Image(icon: icon)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 45, height: 45)
            .font(.largeTitle)
    }
    
    @ViewBuilder
    private var colouredImageView: some View {
        switch colour {
        case let .single(color):
            imageView.foregroundColor(color)
        case let .gradient(colours):
            imageView
                .foregroundStyle(.linearGradient(colors: colours, startPoint: .top, endPoint: .bottom))
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            
            colouredImageView
                .padding(.trailing)
                
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .font(.footnote)
        }
    }
}

struct IndividualFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        IndividualFeatureView(icon: .clock, title: "Organise", description: "Set daily goals and track your progress.", colour: .single(.blue))
    }
}
