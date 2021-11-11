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
    func testEventsFeedWithValidDataResponse_ShouldReturnDecodedObject() async {
        arrangeSutWithValidDataResponseFromNetworkManager()
        let eventsAsStringResult = await sut.eventsFeed(type: [String : String].self)
        switch eventsAsStringResult {
        case .success:
            break
        case .failure:
            XCTFail()
        }
    }
    
    func testEventsFeedWithInvalidDataResponse_ShouldThrowError() async {
        arrangeSutWithInvalidDataResponseFromNetworkManager()
        let eventsAsStringResult = await sut.eventsFeed(type: [String : String].self)
        switch eventsAsStringResult {
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
