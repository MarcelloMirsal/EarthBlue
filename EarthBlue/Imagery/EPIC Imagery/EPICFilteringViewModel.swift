//
//  EPICFilteringViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 08/01/2022.
//

import Foundation

import Foundation
import NetworkingServices

class EPICFilteringViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var isEnhanced: Bool
    
    var defaultAvailableDates: [Date] {
        return [EPICImageryFiltering.defaultFiltering.date, .now]
    }
    
    init(lastImageryFiltering: EPICImageryFiltering?) {
        let imageryFiltering = lastImageryFiltering ?? EPICImageryFiltering.defaultFiltering
        self._isEnhanced = .init(initialValue: imageryFiltering.isEnhanced)
        self._selectedDate = .init(initialValue: imageryFiltering.date)
    }
    
    var datesRange: ClosedRange<Date> {
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: 2015, month: 6, day: 17, hour: 0, minute: 0, second: 0, nanosecond: 0)
        return .init(uncheckedBounds: (lower: dateComponents.date!, upper: EPICImageryFiltering.defaultFiltering.date))
    }
    
    func imageryFiltering() -> EPICImageryFiltering? {
        let currentFiltering = EPICImageryFiltering(date: selectedDate, isEnhanced: isEnhanced)
        return currentFiltering == EPICImageryFiltering.defaultFiltering ? nil : currentFiltering
    }
    
    func restDefaults() {
        selectedDate = EPICImageryFiltering.defaultFiltering.date
        isEnhanced = EPICImageryFiltering.defaultFiltering.isEnhanced
    }
}
