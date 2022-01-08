//
//  EPICImageryRouterTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import XCTest
@testable import NetworkingServices

class EPICImageryRouterTests: XCTestCase {
    
    var sut: EPICImageryRouter!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAPIKey_ShouldBeEqualToExpectKey() {
        let expectedApiKey = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
        
        let apiKey = sut.apiKey
        
        XCTAssertEqual(apiKey, expectedApiKey, "ApiKey should be equal to expected NASA API KEY")
    }
    
    func testBaseURL_ShouldBeEqualToExpectedURL() {
        let expectedURL = URL(string: "https://api.nasa.gov/EPIC/api")!
        
        XCTAssertEqual(sut.baseURL, expectedURL, "base url for EPIC API should be equal to expected url")
    }
    
    func testArchiveBaseURL_ShouldReturnRequestEqualToExpectedURL() {
        let expectedURL = URL(string: "https://epic.gsfc.nasa.gov/archive")!
        
        let archiveBaseURL = sut.archiveBaseURL
        
        XCTAssertEqual(expectedURL, archiveBaseURL)
    }
    
    // MARK: test requests
    func testDefaultEPICFeedRequest_ShouldReturnRequestEqualToExpectedRequest() {
        let expectedURL = URL(string: "https://api.nasa.gov/EPIC/api/natural/images?api_key=K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I")!
        let defaultFeedRequest = sut.defaultFeedRequest()
        
        XCTAssertEqual(expectedURL, defaultFeedRequest.url)
    }
    
    func testThumbImageRequest_ShouldReturnURLEqualToExpectedURL() {
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: 2015, month: 10, day: 31)
        let imageDate = dateComponents.date!
        let imageName = "epic_1b_20151031074844"
        let expectedURL = URL(string: "https://epic.gsfc.nasa.gov/archive/natural/2015/10/31/thumbs/epic_1b_20151031074844.jpg?api_key=\(EPICImageryRouter().apiKey)")
        
        let thumbImageRequest = sut.thumbImageRequest(imageName: imageName, date: imageDate, isEnhanced: false)
        
        XCTAssertEqual(thumbImageRequest.url, expectedURL)
    }
    
    func testThumbImageRequestForEnhanced_ShouldReturnURLEqualToExpectedURL() {
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: 2015, month: 10, day: 31)
        let imageDate = dateComponents.date!
        let imageName = "epic_1b_20151031074844"
        let expectedURL = URL(string: "https://epic.gsfc.nasa.gov/archive/enhanced/2015/10/31/thumbs/epic_1b_20151031074844.jpg?api_key=\(EPICImageryRouter().apiKey)")
        
        let thumbImageRequest = sut.thumbImageRequest(imageName: imageName, date: imageDate, isEnhanced: true)
        
        XCTAssertEqual(thumbImageRequest.url, expectedURL)
    }
    
    func testRequestAvailableDatesForNaturalImages_ShouldReturnURLEqualToExpectedURL() {
        let expectedURL = URL(string: "https://api.nasa.gov/EPIC/api/natural/available?api_key=\(sut.apiKey)")
        
        let naturalAvailableDatesRequest = sut.availableDatesRequest()
        
        XCTAssertEqual(naturalAvailableDatesRequest.url, expectedURL)
    }
    
    func testFilteredFeedRequest_ShouldReturnURLEqualToExpectedURL() {
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, year: 2022, month: 1, day: 6)
        let isImageryEnhanced = false
        let filteringDate = dateComponents.date!
        let expectedURL = URL(string: "https://api.nasa.gov/EPIC/api/natural/date/2022-01-06?api_key=\(sut.apiKey)")!
        
        let filteredFeedRequest = sut.filteredFeedRequest(isImageryEnhanced: isImageryEnhanced, date: filteringDate)
        
        XCTAssertEqual(filteredFeedRequest.url, expectedURL)
    }
}
