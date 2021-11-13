//
//  Grouping.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

enum DateGrouping: CaseIterable, Hashable, Comparable {
    case thisWeek
    case thisMonth
    case previous

    var dateInterval: DateInterval? {

        guard
            let startOfPreviousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now),
            let startOfLastMonthExcludingPreviousWeek = Calendar.current.date(byAdding: .month, value: -1, to: startOfPreviousWeek)
        else { return nil }

        switch self {
        case .thisWeek: return DateInterval.init(
            start: startOfPreviousWeek,
            end: .now
        )
        case .thisMonth: return DateInterval.init(
            start: startOfLastMonthExcludingPreviousWeek,
            end: startOfPreviousWeek
        )

        case .previous: return DateInterval.init(
            start: .distantPast,
            end: startOfLastMonthExcludingPreviousWeek
        )
        }

    }

    var title: String {
        switch self {
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .previous: return "Previous"
        }
    }

}
