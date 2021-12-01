//
//  EventsFilteringViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

class EventsFilteringViewModel {
    func dateRangeEventsFiltering(startDate: Date, endDate: Date, status: String) -> EventsFeedFiltering {
        return EventsFilteringBuilder()
            .set(status: status)
            .set(dateRange: startDate...endDate)
            .build()
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
