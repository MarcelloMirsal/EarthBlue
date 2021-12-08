//
//  EventsFilteringViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/12/2021.
//

import Foundation

class EventsFilteringViewModel: ObservableObject {
    let defaultFeedFiltering = EventsFeedFiltering.defaultFiltering
    @Published private(set) var selectedCategories = Set(Category.defaultCategories)
    let categories = Category.defaultCategories
    var daysRange = 1...730
    
    // MARK: Events Filtering
    func feedFilteringByDateRange(startDate: Date, endDate: Date, status: FeedStatusOptions) -> EventsFeedFiltering? {
        let dateRange = startDate...endDate
        let categories = getSelectedCategoriesIds()
        return EventsFeedFiltering(status: status, filteringType: .dateRange(dateRange), categories: categories)
    }
    
    func feedFiltering(byDays days: Int, status: FeedStatusOptions) -> EventsFeedFiltering {
        let categories = getSelectedCategoriesIds()
        return .init(status: status, filteringType: .days(days), categories: categories)
    }
    
    func formattedNumberOfDays(fromTextFieldString value: String) -> String {
        let filteredValue = value.filter({$0.isNumber})
        guard let numberFromFiltering = Int(filteredValue) else { return filteredValue }
        return daysRange.contains(numberFromFiltering) ? "\(numberFromFiltering)" : "\(daysRange.upperBound)"
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
    
    // MARK: Category operations
    func isCategorySelected(category: Category) -> Bool {
        return selectedCategories.contains(category)
    }
    
    func getSelectedCategoriesIds() -> [String]? {
        guard selectedCategories != Set(categories) else {
            return nil
        }
        return selectedCategories.map({ $0.id })
    }
    
    func setSelectedCategories(byIds ids: [String]?) {
        if let ids = ids {
            let categoriesToSelect = categories.filter({ ids.contains($0.id) })
            selectedCategories = .init(categoriesToSelect)
        } else {
            selectedCategories = .init(categories)
        }
    }
    
    @MainActor
    func handleSelection(forCategory category: Category) {
        if selectedCategories.contains(category) && selectedCategories.count != 1 {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
