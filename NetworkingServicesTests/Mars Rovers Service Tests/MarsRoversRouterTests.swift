//
//  MarsRoversRouterTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 27/01/2022.
//

import XCTest
@testable import NetworkingServices

class MarsRoversRouterTests: XCTestCase {
    
    var sut = MarsRoversRouter()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testApiKey_shouldBeEqualToExpectedAPIKey() {
        let expectedAPIKey = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
        XCTAssertEqual(sut.api_key, expectedAPIKey)
    }
    
    func testBaseURL_ShouldBeEqualToExpectedURL() {
        let expectedStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=\(sut.api_key)"
        XCTAssertEqual(sut.baseURL.absoluteString, expectedStringURL)
    }
    
    func testCuriosityLastAvailableImageryRequest_ShouldReturnURLRequestEqualToExpected() {
        let date = sut.twoDaysBeforeNowStringDate()
        let expectedURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?camera=FHAZ&earth_date=\(date)&api_key=\(sut.api_key)")!
        
        XCTAssertEqual(expectedURL, sut.curiosityLastAvailableImagery().url)
    }
    
    // MARK: Testing Paths
    func testCuriosityPath_ShouldBeEqualToExpectedPath() {
        let expectedPath = "/curiosity/photos"
        XCTAssertEqual(MarsRoversRouter.Paths.curiosityPhotos.rawValue, expectedPath)
    }
    
    
    // MARK: Testing QueryItemsKeys
    func testQueryItemApiKey_ShouldBeEqualToExpectedKey() {
        let expectedApiKey = "api_key"
        XCTAssertEqual(expectedApiKey, MarsRoversRouter.QueryItemsKeys.apiKey.rawValue)
    }
    
    func testQueryItemEarthDate_ShouldBeEqualToExpectedKey() {
        let expectedEarthDateKey = "earth_date"
        XCTAssertEqual(expectedEarthDateKey, MarsRoversRouter.QueryItemsKeys.earthDate.rawValue)
    }
    
    func testQueryItemCamera_ShouldBeEqualToExpectedKey() {
        let expectedKey = "camera"
        XCTAssertEqual(expectedKey, MarsRoversRouter.QueryItemsKeys.camera.rawValue)
    }
    
}
