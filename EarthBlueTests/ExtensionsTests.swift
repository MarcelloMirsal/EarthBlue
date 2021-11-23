//
//  ExtensionsTests.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 22/11/2021.
//

import XCTest
import CoreLocation

class ExtensionsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Test mapping from coordinate array to CLLocationCoordinate2D
    func testInitLocationCoordinateFromDoubls_FirstItemShouldBeLongAndLastShouldBeLat() {
        let coordinateArray: [Double] = [ 1 , 0 ]
        let locationCoordinate = CLLocationCoordinate2D.init(coordinate: coordinateArray)
        XCTAssertEqual(coordinateArray.first!, locationCoordinate.longitude)
        XCTAssertEqual(coordinateArray.last!, locationCoordinate.latitude)
    }
    
}
