//
//  EventDetailsViewModelTests.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 22/11/2021.
//

import XCTest
@testable import EarthBlue
class EventDetailsViewModelTests: XCTestCase {
    
    var sut: EventDetailsViewModel!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init(event: Event.detailedEventMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetEventLocationInfoFromPointCoordinates_ShouldReturnNotEmptyArray() {
        let locationsInfo = sut.locationsInfo()
        
        XCTAssertTrue(!locationsInfo.isEmpty,
                      "locations info should return not empty LocationInfo array that has been mapped from event geometry point coordinates.")
    }
    
    func testGetEventLocationInfoFromPolygonCoordinates_ShouldReturnNotEmptyArray() {
        sut = .init(event: .polygonDetailedEventMock)
        
        let locationsInfo = sut.locationsInfo()
        
        XCTAssertTrue(!locationsInfo.isEmpty,
                      "locations info should return not empty LocationInfo array that has been mapped from event geometry polygon coordinates.")
    }
    
}
