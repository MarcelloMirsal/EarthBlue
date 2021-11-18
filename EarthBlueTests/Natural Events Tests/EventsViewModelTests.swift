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
        let expectation = expectation(description: "testRequestDefaultFeedWithSuccessfulResponse")
        arrangeSutWithMockedNaturalEventsService(forSuccess: true)
        sut.$eventsFeed.dropFirst().sink { eventsFeed in
            XCTAssertFalse(eventsFeed.events.isEmpty)
            expectation.fulfill()
        }.store(in: &cancellable)
        await sut.requestDefaultFeed()
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestDefaultFeedWithFailureResponse_ErrorMessageShouldBeNotNil() async  {
        arrangeSutWithMockedNaturalEventsService(forSuccess: false)
        await sut.requestDefaultFeed()
        XCTAssertTrue(sut.requestStatus == .failed)
    }
    
    func testSetRequestStatus_RequestStatusShouldBeUpdated() {
        let newStatus = EventsViewModel.RequestStatus.success
        sut.set(requestStatus: newStatus)
        
        XCTAssertEqual(sut.requestStatus, newStatus)
    }
    
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
    
    
    // MARK: Sut Arranges
    func arrangeSutWithMockedNaturalEventsService(forSuccess: Bool) {
        sut = .init(naturalEventsService: MockNaturalEventsService(isSuccessResponse: forSuccess ) )
    }
    
}
