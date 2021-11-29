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
    var cancellable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellable.forEach({ $0.cancel() })
    }
    
    // MARK:- Testing service requests
    func testRequestDefaultFeedWithSuccessfulResponse_ShouldSetNewEventsFeed() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        await sut.requestDefaultFeed()
        XCTAssertFalse(sut.events.isEmpty)
    }
    
    func testRequestDefaultFeedWithFailureResponse_ErrorMessageShouldBeNotNil() async  {
        arrangeSutWithMockedNaturalEventsService(forSuccess: false)
        await sut.requestDefaultFeed()
        XCTAssertTrue(sut.requestStatus == .failed)
    }
    
    func testRequestFilteredFeedByDateRange_ShouldSetNewEventsFeed() async {
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        let feedFiltering = EventsFilteringBuilder()
            .set(status: NaturalEventsRouter.EventStatus.all.rawValue)
            .set(dateRange: Date.now...Date.now)
            .build()
        XCTAssertTrue(sut.events.isEmpty)
        await sut.requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
        XCTAssertFalse(sut.events.isEmpty)
    }
    
    func testSetRequestStatus_RequestStatusShouldBeUpdated() {
        let newStatus = EventsViewModel.RequestStatus.success
        sut.set(requestStatus: newStatus)

        XCTAssertEqual(sut.requestStatus, newStatus)
    }
    
    // MARK: Test request result handling
    @MainActor
    func testHandleRequestResultWithSuccessResult_ShouldUpdateStatusToSuccess() async {
        let result = Result<EventsFeed, Error>.success(.init(events: []))
        await sut.handle(feedRequestResult: result)
        XCTAssertEqual(sut.requestStatus, .success)
    }
    
    @MainActor
    func testHandleRequestResultWithFailureResult_ShouldUpdateStatusToFailed() async {
        let result = Result<EventsFeed, Error>.failure(URLError(.badURL))
        await sut.handle(feedRequestResult: result)
        XCTAssertEqual(sut.requestStatus, .failed)
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
