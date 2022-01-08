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
    @Published private(set) var availableDates: [Date]
    @Published var selectedDate: Date = .init()
    @Published var isEnhanced: Bool = false
    private var defaultEPICImageryFiltering: EPICImageryFiltering {
        return .init(date: datesRange.upperBound, isEnhanced: false)
    }
    private let epicImageryService: EPICImageryService
    init() {
        self.availableDates = []
        self.epicImageryService = .init()
        requestAvailableDates()
    }
    
    var datesRange: ClosedRange<Date> {
        guard let startDate = availableDates.first, let endDate = availableDates.last else {
            return .init(uncheckedBounds: (.now, .now))
        }
        return .init(uncheckedBounds: (startDate, endDate))
    }
    
    func restDefaults() {
        selectedDate = datesRange.upperBound
        isEnhanced = false
    }
    
    func imageryFiltering() -> EPICImageryFiltering? {
        let currentFiltering = EPICImageryFiltering(date: selectedDate, isEnhanced: isEnhanced)
        return currentFiltering == defaultEPICImageryFiltering ? nil : currentFiltering
    }
    
    @MainActor
    private func setAvailableDates(stringDates: [String]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.availableDates = stringDates.map({ dateFormatter.date(from: $0) }).compactMap({$0}).sorted()
        set(selectedDate: availableDates.last ?? .now)
    }
    
    @MainActor
    private func set(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    func requestAvailableDates() {
        Task {
            let requestResult = await epicImageryService.requestAvailableDates()
            await handle(datesRequestResult: requestResult)
        }
    }
    
    private func handle(datesRequestResult: Result<[String], Error> ) async {
        switch datesRequestResult {
        case .success(let stringDates):
            await setAvailableDates(stringDates: stringDates)
            
        case .failure:
            requestAvailableDates()
        }
    }
}
