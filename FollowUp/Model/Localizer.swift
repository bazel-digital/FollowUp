//
//  Localizer.swift
//  FollowUp
//
//  Created by Aaron Baw on 20/11/2022.
//

import Foundation

struct Localizer {
    enum Notification {
        static let title: String = "FollowUp"
        static let bodyTemplateString: String = "You met \(Self.numPeopleReplacementToken) \(Self.timeFrameReplacementToken). Would you like to follow up?"
        static let numPeopleReplacementToken: String = "<%NUM_PEOPLE%>"
        static let timeFrameReplacementToken: String = "<%DATE_UNIT%>"
        
        static func body(
            withNumberOfPeople numberOfPeople: Int,
            withinTimeFrame timeFrame: DateGrouping
        ) -> String {
            let stringWithNumPeople = Self.bodyTemplateString.replacingOccurrences(of: Self.numPeopleReplacementToken, with: "\(numberOfPeople) \(numberOfPeople == 1 ? "person" : "people")")
            let stringWithNumPeopleAndTimeFrame = stringWithNumPeople.replacingOccurrences(of: Self.timeFrameReplacementToken, with: timeFrame.title.lowercased())
            
            return stringWithNumPeopleAndTimeFrame
        }
    }
}
