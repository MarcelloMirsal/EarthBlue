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
    
    // MARK: testing EventsFiltering
    func testDefaultFeedFiltering_ShouldReturnDefaultFeedFilteringFromFilteringBuilder() {
        let expectedDefaultFeedFiltering = EventsFilteringBuilder.defaultFeedFiltering
        
        XCTAssertEqual(sut.defaultFeedFiltering, expectedDefaultFeedFiltering,
                       "defaultFeedFiltering should be equal to default feed filtering that provided by EventsFilteringBuilder")
    }
    
    func testDateRangeEventsFiltering_ShouldReturnEventsFilteringWithPassedFilters() {
        let startDate = Date.now.advanced(by: -10000)
        let endDate = Date.now
        let status = FeedStatusOptions.all
        
        guard let eventsFiltering = sut.dateRangeEventsFiltering(startDate: startDate, endDate: endDate, status: status) else {XCTFail() ; return}
        
        XCTAssertEqual(startDate, eventsFiltering.dateRange!.lowerBound)
        XCTAssertEqual(endDate, eventsFiltering.dateRange!.upperBound)
        XCTAssertEqual(status, eventsFiltering.status)
        
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
