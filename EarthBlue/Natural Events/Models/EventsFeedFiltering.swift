//
//  EventsFeedFiltering.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

struct EventsFeedFiltering: Equatable {
    static let defaultFiltering = Self(status: .all, filteringType: .days(60))
    let id = UUID()
    let status: FeedStatusOptions
    let filteringType: FilteringType
    
    enum FilteringType: Equatable {
        case dateRange(ClosedRange<Date>)
        case days(Int)
    }
}
