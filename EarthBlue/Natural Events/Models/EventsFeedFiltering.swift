//
//  EventsFeedFiltering.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

struct EventsFeedFiltering: Equatable {
    let status: String
    let dateRange: ClosedRange<Date>?
}

struct EventsFilteringBuilder {
    let eventsFiltering: EventsFeedFiltering
    init() {
        self.eventsFiltering = .init(status: "", dateRange: nil)
    }
    
    private init(status: String, dateRange: ClosedRange<Date>?) {
        self.eventsFiltering = .init(status: status, dateRange: dateRange)
    }
    
    func set(status: String) -> Self {
        return .init(status: status, dateRange: self.eventsFiltering.dateRange)
    }
    
    func set(dateRange: ClosedRange<Date>?) -> Self {
        return .init(status: self.eventsFiltering.status, dateRange: dateRange)
    }
    
    func build() -> EventsFeedFiltering {
        return eventsFiltering
    }
}

