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
    var sut: NaturalEventsRouter!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBaseURLComponent_ShouldReturnIdealBaseURL() {
        let idealBaseURL = URL(string: "https://eonet.sci.gsfc.nasa.gov/api/v3/events")!
        let baseURL = sut.baseURLComponent
        XCTAssertEqual(idealBaseURL, baseURL.url)
    }
    
    // MARK: Testing QueryItems
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
        let idealURL = URL(string: "https://eonet.sci.gsfc.nasa.gov/api/v3/events?status=all&days=60")!
        let defaultFeedRequest = sut.defaultFeedRequest()
        XCTAssertEqual(idealURL, defaultFeedRequest.url!)
    }
}
