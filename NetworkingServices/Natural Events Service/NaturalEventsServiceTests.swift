//
//  NaturalEventsServiceTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import XCTest
@testable import NetworkingServices


class NaturalEventsServiceTests: XCTestCase {

    var sut: NaturalEventsService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Testing Init
    func testInit_ShouldSetThePassedNetworkManager() {
        let customNetworkManager = NetworkManager()
        sut = .init(networkManager: customNetworkManager)
        XCTAssertTrue(sut.networkManager === customNetworkManager)
    }
    
    // MARK: Testing eventsFeed
    func testDefaultEventsFeedWithValidDataResponse_ShouldReturnDecodedObject() async {
        arrangeSutWithValidDataResponseFromNetworkManager()
        let feedResult = await sut.defaultEventsFeed(type: [String : String].self)
        switch feedResult {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }
    
    func testDefaultEventsFeedWithInvalidDataResponse_ShouldReturnFailureResult() async {
        arrangeSutWithInvalidDataResponseFromNetworkManager()
        let feedResult = await sut.defaultEventsFeed(type: [String : String].self)
        switch feedResult {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertNotNil(error as? URLError)
        }
    }
    
    func testFilteredEventsFeedWithValidDataResponse_ShouldReturnDecodedObject() async {
        arrangeSutWithValidDataResponseFromNetworkManager()
        let dateRange = Date.now.advanced(by: -1000)...Date.now
        let feedResult = await sut.filteredEventsFeed(dateRange: dateRange, status: .open, type: [String : String].self)
        switch feedResult {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }
    
    func testFilteredEventsFeedWithInvalidDataResponse_ShouldReturnFailureResult() async {
        arrangeSutWithInvalidDataResponseFromNetworkManager()
        let dateRange = Date.now.advanced(by: -1000)...Date.now
        let feedResult = await sut.filteredEventsFeed(dateRange: dateRange, status: .closed, type: [String : String].self )
        switch feedResult {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertNotNil(error as? URLError)
        }
    }
    
    // MARK: Sut Arranges
    func arrangeSutWithValidDataResponseFromNetworkManager() {
        let mockNetworkManager = MockNetworkManager(isSuccess: true)
        sut = .init(networkManager: mockNetworkManager)
    }
    
    func arrangeSutWithInvalidDataResponseFromNetworkManager() {
        let mockNetworkManager = MockNetworkManager(isSuccess: false)
        sut = .init(networkManager: mockNetworkManager)
    }
}
