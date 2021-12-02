//
//  EventsFeedFiltering.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

struct EventsFeedFiltering: Equatable {
    let id = UUID()
    let status: FeedStatusOptions
    var dateRange: ClosedRange<Date>?
}

struct EventsFilteringBuilder {
    static let defaultFeedFiltering: EventsFeedFiltering = Self()
        .set(status: .all)
        .set(dateRange: Date.now...Date.now)
        .build()
    let eventsFiltering: EventsFeedFiltering
    init() {
        self.eventsFiltering = .init(status: .all, dateRange: nil)
    }
    
    private init(status: FeedStatusOptions, dateRange: ClosedRange<Date>?) {
        self.eventsFiltering = .init(status: status, dateRange: dateRange)
    }
    
    func set(status: FeedStatusOptions) -> Self {
        return .init(status: status, dateRange: self.eventsFiltering.dateRange)
    }
    
    func set(dateRange: ClosedRange<Date>?) -> Self {
        return .init(status: self.eventsFiltering.status, dateRange: dateRange)
    }
    
    func build() -> EventsFeedFiltering {
        return eventsFiltering
    }
}

