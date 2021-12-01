//
//  EventsViewModelTests.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 13/11/2021.
//

import XCTest
import Combine
@testable import EarthBlue
@testable import NetworkingServices

class EventsViewModelTests: XCTestCase {
    var sut: EventsViewModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK:- Testing service requests
    func testRequestDefaultFeedWithSuccessfulResponse_EventsFeedShouldBeNotEmpty() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        
        await sut.requestDefaultFeed()
        
        XCTAssertFalse(sut.events.isEmpty,
                       "events feed should be not empty when request succeed.")
    }
    
    func testRequestDefaultFeedWithFailedResponse_ErrorMessageShouldBeNotNil() async  {
        arrangeSutWithMockedNaturalEventsService(forSuccess: false)
        
        await sut.requestDefaultFeed()
        
        XCTAssertNotNil(sut.errorMessage,
                        "Error message should be not nil when an error occurred, it must have the error message.")
    }
    
    func testRequestFilteredFeedWithSuccessfulResponse_EventsFeedShouldBeNotEmpty() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        let feedFiltering = EventsFilteringBuilder()
            .set(status: NaturalEventsRouter.EventStatus.all.rawValue)
            .set(dateRange: Date.now...Date.now)
            .build()
        
        await sut.requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
        
        XCTAssertFalse(sut.events.isEmpty,
                       "events feed should be not empty when request succeed.")
    }
    
    func testRequestFilteredFeedWithFailedResponse_ErrorMessageShouldBeNotNil() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: false)
        let feedFiltering = EventsFilteringBuilder()
            .set(status: NaturalEventsRouter.EventStatus.all.rawValue)
            .set(dateRange: Date.now...Date.now)
            .build()
        
        await sut.requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
        
        XCTAssertNotNil(sut.errorMessage,
                       "Error message should be not nil when an error occurred, it must have the error message.")
    }
    
    func testRequestFilteredFeedWithNilDateRange_ShouldCancelRequestAndReturn() async {
        let feedFiltering = EventsFeedFiltering(status: "all", dateRange: nil)
        XCTAssertTrue(sut.events.isEmpty)
        
        await sut.requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
        
        XCTAssertTrue(sut.events.isEmpty, "when date range is nil requesting filtered events should return and not change the state of the model.")
    }
    
    func testRefreshEventsFeedForDefaultEvents_EventsFeedShouldBeNotEmpty() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        
        await sut.refreshEventsFeed()
        
        XCTAssertFalse(sut.events.isEmpty, "refreshing an empty feed should request new default events feed and show it.")
    }
    
    func testRefreshEventsFeedForFilteredEvents_EventsFeedShouldBeNotEmpty() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        sut.set(feedFiltering: .init(status: "all", dateRange: Date.now...Date.now))
        
        await sut.refreshEventsFeed()
        
        XCTAssertFalse(sut.events.isEmpty, "refreshing an empty filtered feed should request new filtered events feed and show it.")
    }
    
    func testRequestStatus_ShouldBeEqualToSuccessWhenInitialized() {
        XCTAssertEqual(sut.requestStatus, .success, "request should be in success status when first initialized, to allow the UI to send new feed requests, if request == success new request can be placed.")
    }
    
    func testSetRequestStatus_RequestStatusShouldBeUpdated() {
        let newStatus = EventsViewModel.RequestStatus.success
        
        sut.set(requestStatus: newStatus)

        XCTAssertEqual(sut.requestStatus, newStatus, "request status should be updated to the new passed status.")
    }
    
    // MARK: Test request result handling
    @MainActor
    func testHandleRequestResultWithSuccessResult_ShouldUpdateStatusToSuccess() async {
        let result = Result<EventsFeed, Error>.success(.init(events: []))
        
        await sut.handle(feedRequestResult: result)
        
        XCTAssertEqual(sut.requestStatus, .success, "request status should be set to success to update the UI for success situation.")
    }
    
    @MainActor
    func testHandleRequestResultWithSuccessResult_ShouldSetTheNewEventsFeed() async {
        let newEvents: [Event] = [ .activeEventMock, .closedEventMock ]
        let result = Result<EventsFeed, Error>.success(.init(events: newEvents))
        
        await sut.handle(feedRequestResult: result)
        
        XCTAssertFalse(sut.events.isEmpty)
        XCTAssertEqual(sut.events, newEvents, "events feed should be equal to the new passed events.")
    }
    
    @MainActor
    func testHandleRequestResultWithFailureResult_ShouldUpdateStatusToFailed() async {
        let result = Result<EventsFeed, Error>.failure(URLError(.badURL))
        
        await sut.handle(feedRequestResult: result)
        
        XCTAssertEqual(sut.requestStatus, .failed, "request status should be set to failed, to send UI changes for failed situation. ")
    }
    
    @MainActor
    func testHandleRequestResultWithFailureResult_ErrorMessageShouldBeNotNil() async {
        let result = Result<EventsFeed, Error>.failure(URLError(.badURL))
        
        await sut.handle(feedRequestResult: result)
        
        XCTAssertNotNil(sut.errorMessage,
                        "error message should be not nil when an error occurred.")
    }
    
    // MARK: Searching tests
    func testFilterEvents_ShouldReturnFilteredEvents() async  {
        let searchText = "ice"
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        await sut.requestDefaultFeed()
        let filteredEvents = sut.filteredEvents(withName: searchText)
        XCTAssertTrue(!filteredEvents.isEmpty)
    }
    
    // MARK: Sut Arranges
    func arrangeSutWithMockedNaturalEventsService(forSuccess: Bool) {
        sut = .init(naturalEventsService: MockNaturalEventsService(isSuccessResponse: forSuccess ) )
    }
    
}
