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
    
    func testGetEventLocationInfo_ShouldReturnNotEmptyArray() {
        let locationsInfo = sut.locationsInfo()
        XCTAssertTrue(!locationsInfo.isEmpty)
    }
    
}
