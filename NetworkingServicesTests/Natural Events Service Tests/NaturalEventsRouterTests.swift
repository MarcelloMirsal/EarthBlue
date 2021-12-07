//
//  NaturalEventsRouterTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import XCTest
@testable import NetworkingServices

class NaturalEventsRouterTests: XCTestCase {
    private typealias QueryItem = NaturalEventsRouter.QueryItem
    let idealBaseURL = URL(string: "https://eonet.gsfc.nasa.gov/api/v3/events")!
    var sut: NaturalEventsRouter!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBaseURLComponent_ShouldReturnIdealBaseURL() {
        let baseURL = sut.baseURLComponent
        XCTAssertEqual(idealBaseURL, baseURL.url)
    }
    
    func testStringDateForQuery_ShouldReturnDateEqualToIdeal() {
        let idealDateFormation = "2001-01-01"
        let date = Date.init(timeIntervalSinceReferenceDate: 0)
        let stringDate = sut.stringDateForQuery(from: date)
        XCTAssertEqual(stringDate, idealDateFormation)
    }
    
    // MARK: Testing QueryItems
    func testQueryItemRawValues() {
        XCTAssertEqual(QueryItem.days.rawValue, "days")
        XCTAssertEqual(QueryItem.status.rawValue, "status")
        XCTAssertEqual(QueryItem.startDate.rawValue, "start")
        XCTAssertEqual(QueryItem.endDate.rawValue, "end")
        XCTAssertEqual(QueryItem.category.rawValue, "category")
    }
    
    func testDefaultQueryItems_ShouldReturnIdealQueryItem() {
        let defaultDays = "60"
        let defaultStatus = "all"
        let idealStatusQueryItem = QueryItem.status.queryItem(withValue: defaultStatus)
        let idealDaysQueryItem = QueryItem.days.queryItem(withValue: defaultDays)
        
        let statusQueryItem = QueryItem.defaultStatus
        let daysQueryItem = QueryItem.defaultDays
        
        XCTAssertEqual(idealStatusQueryItem, statusQueryItem)
        XCTAssertEqual(idealDaysQueryItem, daysQueryItem)
    }
    
    // MARK: Testing Requests
    func testEventsFeedURLRequest_ShouldReturnDefaultFeedRequest() {
        let idealURL = URL(string: "\(idealBaseURL.absoluteString)?status=all&days=60")!
        let defaultFeedRequest = sut.defaultFeedRequest()
        XCTAssertEqual(idealURL, defaultFeedRequest.url!)
    }
    
    func testFilteredEventsRequest_ShouldReturnRequestWithThePassedParams() {
        let startDateValue = "2021-01-01"
        let endDateValue = "2021-12-31"
        let status = NaturalEventsRouter.EventsStatus.all
        let idealURL = URL(string:  "\(idealBaseURL.absoluteString)?start=\(startDateValue)&end=\(endDateValue)&status=all")!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: startDateValue)!
        let endDate = dateFormatter.date(from: endDateValue)!
        
        let dateRange = startDate...endDate
        
        let filteredFeedRequest = sut.filteredFeedRequest(dateRange: dateRange, forStatus: status)
        XCTAssertEqual(filteredFeedRequest.url, idealURL)
    }
    
    func testFilteredEventsRequestByDates_ShouldReturnRequestWithPassedParamsAsExpecteURL() {
        let days = 60
        let status = NaturalEventsRouter.EventsStatus.all
        let expectedURL = URL(string:  "\(idealBaseURL.absoluteString)?days=\(days)&status=\(status.rawValue)")!
        
        let filteredFeedRequest = sut.filteredFeedRequest(days: days, forStatus: status)
        
        XCTAssertEqual(filteredFeedRequest.url, expectedURL,
                       "filtered feed URL should be equal to the expected URL")
    }
    
    func testFilteredEventsRequestWithCategories_ShouldReturnRequestWithPassedCategories() {
        let days = 60
        let status = NaturalEventsRouter.EventsStatus.all
        let expectedURL = URL(string:  "\(idealBaseURL.absoluteString)?days=\(days)&status=\(status.rawValue)&category=1,2")!
        
        let filteredFeedRequest = sut.filteredFeedRequest(days: days, forStatus: .all, categories: ["1", "2"])
        
        XCTAssertEqual(expectedURL, filteredFeedRequest.url)
    }
    
}
