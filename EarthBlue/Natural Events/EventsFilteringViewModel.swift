//
//  EventsFilteringViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

class EventsFilteringViewModel {
    
    let defaultFeedFiltering = EventsFeedFiltering.defaultFiltering
    
    var daysRange: ClosedRange<Int> {
        return 1...730
    }
    
    func formattedNumberOfDays(fromTextFieldString value: String) -> String {
        return value.filter({$0.isNumber})
    }
    
    func dateRangeEventsFiltering(startDate: Date, endDate: Date, status: FeedStatusOptions) -> EventsFeedFiltering? {
        let dateRange = startDate...endDate
        return EventsFeedFiltering(status: status, filteringType: .dateRange(dateRange))
    }
    
    func feedFiltering(byDays days: Int, status: FeedStatusOptions) -> EventsFeedFiltering {
        return .init(status: status, filteringType: .days(days))
    }
    
    func startingDatePickerRange() -> ClosedRange<Date> {
        let lowerBoundDate = Date.init(timeIntervalSinceReferenceDate: 0)
        let upperBoundDate = Date.now
        return .init(uncheckedBounds: (lower: lowerBoundDate, upper: upperBoundDate))
    }
    
    func endingDatePickerRange(startDate: Date) -> ClosedRange<Date> {
        let yearsAdvanceFactor = 2
        let endDate = Calendar.current.date(byAdding: .year, value: yearsAdvanceFactor, to: startDate)!
        let upperBoundDate = endDate > .now ? Date.now : endDate
        return .init(uncheckedBounds: (lower: startDate, upper: upperBoundDate))
    }
}
