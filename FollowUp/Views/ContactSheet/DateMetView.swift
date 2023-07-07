//
//  DateMetView.swift
//  FollowUp
//
//  Created by Aaron Baw on 07/07/2023.
//

import SwiftUI

struct DateMetView: View {
    
    enum ViewMode: CaseIterable, Equatable {
        case relative
        case absolute
    }
    
    var contact: any Contactable
    @State private var viewMode: ViewMode = .relative
    
    // MARK: - Views
    private var relativeTimeSinceMeetingString: String {
        Constant.relativeDateTimeFormatter.localizedString(for: contact.createDate, relativeTo: .now)
    }

    private var absoluteTimeWhenMetString: String {
        contact.createDate.formatted(.dateTime.day().month(.wide).year().hour().minute())
    }

    
    private var relativeTimeSinceMeetingView: some View {
        (Text(Image(icon: .clock)) +
         Text(" Met ") +
         Text(relativeTimeSinceMeetingString))
            .fontWeight(.medium)
    }
    
    private var absoluteTimeWhenMetView: some View {
        (Text(Image(icon: .clock)) +
         Text(" Met ") +
         Text(absoluteTimeWhenMetString))
            .fontWeight(.medium)
    }
    
    var body: some View {
        Button(action: {
            self.toggleViewMode()
        }, label: {
            switch self.viewMode {
            case .absolute: absoluteTimeWhenMetView
            case .relative: relativeTimeSinceMeetingView
            }
        }).foregroundColor(.secondary)
    }
    
    // MARK: - Methods
    private func toggleViewMode(){
        self.viewMode = self.viewMode == .absolute ? .relative : .absolute
    }
}

struct DateMetView_Previews: PreviewProvider {
    static var previews: some View {
        DateMetView(contact: Contact.mockedFollowedUpToday)
    }
}
