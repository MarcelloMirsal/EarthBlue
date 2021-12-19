//
//  EventBookmarkStoreTests.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 15/12/2021.
//

import XCTest
@testable import EarthBlue

class EventBookmarkStoreTests: XCTestCase {
    
    var sut: EventBookmarkStore!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testStoreFilename_ShouldBeEqualToExpectedFilename() {
        let expectedFilename = "EventsBookmarkStore.plist"
        XCTAssertEqual(expectedFilename, sut.filename)
    }
    
    func testStoreFileURL_ShouldBeEqualToDocumentsInUserDomainPath() {
        let expectedURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(sut.filename)
        
        XCTAssertEqual(expectedURL, sut.storeFileURL,
                       "Store file URL should be in the documents directory under userDomainMask.")
    }
}
