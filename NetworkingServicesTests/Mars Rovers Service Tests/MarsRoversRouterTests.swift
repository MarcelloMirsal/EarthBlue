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
        XCTAssertEqual(sut.apiKey, expectedAPIKey)
    }
    
    func testBaseURL_ShouldBeEqualToExpectedURL() {
        let expectedStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=\(sut.apiKey)"
        XCTAssertEqual(sut.baseURL.absoluteString, expectedStringURL)
    }
    
    func testLastAvailableImageryRequest_ShouldReturnURLRequestEqualToStrategyLastImageriesRequest() {
        let expectedURL = sut.routingStrategy.lastAvailableImageryRequest()
        XCTAssertEqual(expectedURL, sut.lastAvailableImagery())
    }
    
    func testFilteredImageries_ShouldReturnRequestEqualToStrategyRequest() {
        let date = Date.now
        let stringDate = DateFormatter.string(from: date)
        let expectedURL = sut.routingStrategy.filteredImageriesRequest(date: stringDate, cameraType: nil)
        
        XCTAssertEqual(expectedURL, sut.filteredImageriesRequest(date: date, cameraType: nil))
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


class MarsRoversRoutingStrategiesTests: XCTestCase {
    let router = MarsRoversRouter()
    var sut: CuriosityRoverRoutingStrategy!
    
    override func setUp() {
        sut = CuriosityRoverRoutingStrategy(baseURL: router.baseURL)
    }
    
    func testLastAvailableImageriesRequest_ShouldReturnRequestEqualToExpectedRequestURL() {
        let imageriesStringDate = sut.twoDaysBeforeNowStringDate()
        let expectedURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?camera=FHAZ&earth_date=\(imageriesStringDate)&api_key=\(router.apiKey)")
        
        XCTAssertEqual(expectedURL, sut.lastAvailableImageryRequest().url)
    }
    
    func testFilteredRequest_ShouldReturnRequestWithThePassedParams() {
        let stringDate = "2022-1-29"
        let cameraType = "RHAZ"
        let expectedURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?camera=\(cameraType)&earth_date=\(stringDate)&api_key=\(router.apiKey)")
        
        let filteredFeedRequest = sut.filteredImageriesRequest(date: stringDate, cameraType: cameraType)
        
        XCTAssertEqual(filteredFeedRequest.url, expectedURL)
    }
    
    func testFilteredRequestWithNilCameraType_ShouldReturnRequestWithThePassedParams() {
        let stringDate = "2022-1-29"
        let cameraType: String? = nil
        let expectedURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=\(stringDate)&api_key=\(router.apiKey)")
        
        let filteredFeedRequest = sut.filteredImageriesRequest(date: stringDate, cameraType: cameraType)
        
        XCTAssertEqual(filteredFeedRequest.url, expectedURL)
    }
}
