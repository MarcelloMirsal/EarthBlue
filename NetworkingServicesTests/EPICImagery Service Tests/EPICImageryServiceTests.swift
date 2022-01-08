//
//  EPICImageryServiceTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import XCTest
@testable import NetworkingServices

class EPICImageryServiceTests: XCTestCase {
    
    var sut: EPICImageryService!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init(networkManager: MockNetworkManager(isSuccess: true) )
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testRequestDefaultFeedWithSuccessfulResponse_ShouldReturnSuccessResult() async {
        let result = await sut.requestDefaultFeed(decodableType: [String : String]?.self)
        switch result {
        case .success(let decodedObject):
            XCTAssertNotNil(decodedObject)
        case .failure:
            XCTFail()
        }
    }
    
    func testRequestDefaultFeedWithFailureNetworkResponse_ShouldReturnFailureResultWithNetworkError() async {
        sut = .init(networkManager: MockNetworkManager(isSuccess: false))
        let result = await sut.requestDefaultFeed(decodableType: [String : String]?.self)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            let serviceError = error as? ServiceError
            XCTAssertNotNil(serviceError)
        }
    }
    
    func testRequestDefaultFeedWithBadDecodingType_ShouldReturnFailureResultWithDecodingError() async {
        sut = .init(networkManager: MockNetworkManager(isSuccess: true))
        let result = await sut.requestDefaultFeed(decodableType: Int.self)
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            let serviceError = error as? ServiceError
            XCTAssertNotNil(serviceError)
            XCTAssertTrue(serviceError == .decoding)
        }
    }
    
    func testRequestFilteredFeedSuccessfulResult() async {
        let result = await sut.requestDefaultFeed(decodableType: [String : String]?.self)
        switch result {
        case .success(let decodedObject):
            XCTAssertNotNil(decodedObject)
        case .failure:
            XCTFail()
        }
    }
    
    func testRequestAvailableDatesWithWrongDataResponse_ShouldReturnFailureResult() async {
        let result = await sut.requestAvailableDates()
        switch result {
        case .success:
            XCTFail()
        case .failure(let error):
            XCTAssertNotNil(error as? ServiceError)
        }
    }
    
    func testRequestAvailableDates_ShouldReturnSuccessResult() async {
        let datesArray = ["2015-06-13" , "2015-06-13" , "2015-06-13" , "2015-06-13"]
        let jsonData = try! JSONEncoder().encode(datesArray)
        let jsonStringData = String(data: jsonData, encoding: .utf8)!
        sut = .init(networkManager: MockNetworkManager(isSuccess: true, stringData: jsonStringData))
        
        let result = await sut.requestAvailableDates()
        
        switch result {
        case .success(let dates):
            XCTAssertFalse(dates.isEmpty)
        case .failure:
            XCTFail()
        }
    }
    
    func testRequestFilteredFeed_ShouldReturnSuccessfulResult() async {
        sut = .init(networkManager: MockNetworkManager(isSuccess: true))
        let result = await sut.requestFilteredFeed(isImageryEnhanced: false, date: .now, decodingType: [String : String].self)
        switch result {
        case .success(let decodingType):
            XCTAssertNotNil(decodingType)
        case .failure:
            XCTFail()
        }
    }
    
}
