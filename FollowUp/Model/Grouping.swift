//
//  Grouping.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

enum Grouping: Hashable, Comparable {
    case relativeDate(grouping: RelativeDateGrouping)
    case concreteDate(grouping: ConcreteDateGrouping)
    case new

    var title: String {
        switch self {
        case let .concreteDate(dateGrouping):
            return dateGrouping.title
        case let .relativeDate(dateGrouping):
            return dateGrouping.title
        case .new:
            return "New"
        }
    }
}

enum ConcreteDateGrouping: Hashable, Comparable {
    
    
    case dayMonthYear(day: Int, month: Int, year: Int)
    case monthYear(month: Int, year: Int)
    
    static func dayMonthYear(forDate date: Date) -> ConcreteDateGrouping {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard
            let day = components.day,
            let month = components.month,
            let year = components.year
        else { return .dayMonthYear(day: 0, month: 0, year: 0) }
        return .dayMonthYear(day: day, month: month, year: year)
    }

    static func monthYear(forDate date: Date) -> ConcreteDateGrouping {
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        guard
            let month = components.month,
            let year = components.year
        else { return .monthYear(month: 0, year: 0) }
        return .monthYear(month: month, year: year)
    }

    var dateInterval: DateInterval? {
        switch self {
        case let .dayMonthYear(day, month, year):
            guard
                let startOfDay = self.startOf(day: day, month: month, year: year),
                let endOfDay = self.endOf(day: day, month: month, year: year)
            else { return nil }
            return .init(start: startOfDay, end: endOfDay)
        case let .monthYear(month, year):
            guard
                let startOfMonth = self.startOf(month: month, ofYear: year),
                let endOfMonth = self.endOf(month: month, ofYear: year)
            else { return nil }
            return .init(start: startOfMonth, end: endOfMonth)
        }
    }
    
    var title: String {
        switch self {
        case let .monthYear(month, year):
            let components = DateComponents(year: year, month: month, day: 0, hour: 0, minute: 0, second: 0)
            guard let date = Calendar.current.date(from: components) else { return "Unknown Date" }
            return Self.monthYearDateFormatter.string(from: date)
        case let .dayMonthYear(day, month, year):
            let components = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
            guard let date = Calendar.current.date(from: components) else { return "Unknown Date" }
            return Self.dayMonthYearFormatter.string(from: date)
        }
    }
    
    // MARK: - Static Properties
    static let monthYearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let dayMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Comparable Conformance
    static func < (lhs: ConcreteDateGrouping, rhs: ConcreteDateGrouping) -> Bool {
        return (lhs.dateInterval ?? DateInterval()) < (rhs.dateInterval ?? DateInterval())
    }
    
    // MARK: - Methods
    
    private func startOf(day: Int, month: Int, year: Int) -> Date? {
        let startOfDayComponents = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
        return Calendar.current.date(from: startOfDayComponents)
    }
    
    private func endOf(day: Int, month: Int, year: Int) -> Date? {
        let endOfDayComponents = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
        return Calendar.current.date(from: endOfDayComponents)
    }
    
    private func startOf(month: Int, ofYear year: Int) -> Date? {
        let startOfMonthComponents = DateComponents(year: year, month: month, day: 1)
        return Calendar.current.date(from: startOfMonthComponents)
    }
    
    private func endOf(month: Int, ofYear year: Int) -> Date? {
        // By using 'day: 0', we are able to refer to the last day of the previous month.
        let endOfMonthComponents = DateComponents(year: year, month: month + 1, day: 0)
        return Calendar.current.date(from: endOfMonthComponents)
    }
}

enum RelativeDateGrouping: CaseIterable, Hashable, Comparable {
    
    case today
    case week
    case month
    case beforeLastMonth

    var dateInterval: DateInterval? {
        
        guard
            let startOfToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: .now),
            let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday),
            let startOfPreviousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now),
            let startOfLastMonthExcludingPreviousWeek = Calendar.current.date(byAdding: .month, value: -1, to: startOfPreviousWeek)
        else { return nil }
        
        switch self {
            case .today: return DateInterval.init(
                start: startOfToday,
                end: endOfToday
            )
                
            case .week: return DateInterval.init(
                start: startOfPreviousWeek,
                end: .now
            )
                
            case .month: return DateInterval.init(
                start: startOfLastMonthExcludingPreviousWeek,
                end: startOfPreviousWeek
            )
                
            case .beforeLastMonth: return DateInterval.init(
                start: .distantPast,
                end: startOfLastMonthExcludingPreviousWeek
            )
        }
        
    }

    var title: String {
        switch self {
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .beforeLastMonth: return "Previous"
        }
    }

}
