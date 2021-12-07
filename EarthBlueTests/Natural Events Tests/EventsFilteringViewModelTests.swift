//
//  EventsFilteringViewModelTests.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 26/11/2021.
//

import XCTest
@testable import EarthBlue
class EventsFilteringViewModelTests: XCTestCase {
    
    var sut: EventsFilteringViewModel!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSelectedCategoriesAfterInit_ShouldBeEqualToDefaultCategories() {
        let defaultCategories = Category.defaultCategories
        let selectedCategories = Array(sut.selectedCategories).sorted()
        
        XCTAssertEqual(defaultCategories, selectedCategories,
                       "selected categories should be equal to all default categories when initialized.")
    }
    
    func testCategories_ShouldBeEqualToDefaultCategories() {
        let defaultCategories = Category.defaultCategories
        
        let categories = sut.categories
        
        XCTAssertEqual(categories, defaultCategories,
                       "categories should be equal to default categories, this property used for UI where categories are presented for selection.")
    }

    func testFormattedNumberOfDaysFromTextFieldString_ShouldExtractNumbersFromString() {
        let textFieldValue = "1m2,3"
        let expectedValue = "123"
        
        let formattedNumberOfDays = sut.formattedNumberOfDays(fromTextFieldString: textFieldValue)
        
        XCTAssertEqual(formattedNumberOfDays, expectedValue)
    }
    
    func testDaysRange_ShouldReturnRangeFromOneDayToTwoYearsInDays() {
        let expectedDays = 1...730
        
        let daysRangeFilter = sut.daysRange
        
        XCTAssertEqual(daysRangeFilter, expectedDays,
                       "days range should be between 1...730 (one day -> two years)")
    }
    
    // MARK: testing EventsFiltering
    func testDefaultFeedFiltering_ShouldReturnDefaultFeedFilteringFromFilteringBuilder() {
        let expectedDefaultFeedFiltering = EventsFeedFiltering.defaultFiltering
        
        XCTAssertEqual(sut.defaultFeedFiltering, expectedDefaultFeedFiltering,
                       "defaultFeedFiltering should be equal to default feed filtering that provided by EventsFilteringBuilder")
    }
    
    func testDateRangeEventsFiltering_ShouldReturnEventsFilteringWithPassedFilters() async {
        let startDate = Date.now.advanced(by: -10000)
        let endDate = Date.now
        let status = FeedStatusOptions.all
        
        guard let eventsFiltering = sut.dateRangeEventsFiltering(startDate: startDate, endDate: endDate, status: status) else {XCTFail() ; return}
        guard case .dateRange(let dateRange) = eventsFiltering.filteringType else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(startDate, dateRange.lowerBound)
        XCTAssertEqual(endDate, dateRange.upperBound)
        XCTAssertEqual(status, eventsFiltering.status)
    }
    // MARK: Testing Events Filtering by Days
    func testEventsFeedFilteringByDays_ShouldReturnFilteringWithDaysFilterngTypeAndPaasedDays() {
        let days = 60
        let status = FeedStatusOptions.closed
        let feedFiltering = sut.feedFiltering(byDays: days, status: status)
        
        XCTAssertEqual(feedFiltering.status, status,
                       "status should be equal to the passed status")
        XCTAssertEqual(feedFiltering.filteringType, .days(days),
                       "filtering type should be equal to the passed type")
    }
    
    // MARK: testing date ranges
    func testEndingDatePickerRange_ShouldReturnDateRangeAdvancedByTwoYears() {
        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate  = Calendar.current.date(byAdding: .year, value: 2, to: startDate)!
        
        let dateRange = sut.endingDatePickerRange(startDate: startDate)
        
        XCTAssertEqual(dateRange.lowerBound, startDate)
        XCTAssertEqual(dateRange.upperBound, endDate)
    }
    
    func testEndingDatePickerRangeWithStartDateYearIsLessThanTwo_ShouldReturnDateRangeAdvancedToCurrentYear() {
        let startDate = Date(timeIntervalSinceNow: -1000)
        
        let dateRange = sut.endingDatePickerRange(startDate: startDate)
        
        XCTAssertEqual(dateRange.lowerBound, startDate)
        XCTAssertEqual(dateRange.upperBound.formatted(), Date.now.formatted())
    }
    
    func testStartingDatePickerRange_ShouldReturnRangeBetween2001ToCurrentYear() {
        let startingDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = Date.now
        
        let startingDatePickerRange = sut.startingDatePickerRange()
        
        // formation used here at avoid time checking when comparing, while startingDate and range lowerBound is using the same date and time there's no need for formation
        let formattedEndDate = endDate.formatted(date: .complete, time: .omitted)
        let formattedDateRangeUpperBound = startingDatePickerRange.upperBound.formatted(date: .complete, time: .omitted)
        
        XCTAssertEqual(startingDatePickerRange.lowerBound, startingDate)
        XCTAssertEqual(formattedDateRangeUpperBound, formattedEndDate)
    }
    
    
}
