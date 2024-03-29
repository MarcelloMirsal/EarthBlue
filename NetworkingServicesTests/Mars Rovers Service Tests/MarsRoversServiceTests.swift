//
//  MarsRoversServiceTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 27/01/2022.
//

import XCTest
@testable import NetworkingServices

class MarsRoversServiceTests: XCTestCase {
    
    let roverId = MarsRoversRouter.Rovers.curiosity.rawValue
    var sut: MarsRoversService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = .init(roverId: roverId)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRequestLastImageriesWithValidResponse_ShouldReturnSuccessResult() async {
        arrangeSUTWithMockedNetworkManger(isResponseSuccess: true)
        
        let requestResult = await sut.requestLastImageries(decodingType: [String : String].self)
        
        switch requestResult {
        case .success:
            break
        case .failure:
            XCTFail("result should success.")
        }
    }
    
    func testRequestLastImageriesWithWrongDecoding_ShouldReturnDecodingError() async {
        arrangeSUTWithMockedNetworkManger(isResponseSuccess: true)
        
        let requestResult = await sut.requestLastImageries(decodingType: Int.self)
        
        switch requestResult {
        case .success:
            XCTFail("result should failed with decoding error")
        case let .failure(error):
            let serviceError = error as! ServiceError
            
            XCTAssertEqual(serviceError, ServiceError.decoding)
        }
    }
    
    func testRequestLastImageriesWithInvalidResponse_ShouldReturnNetworkingError() async {
        arrangeSUTWithMockedNetworkManger(isResponseSuccess: false)
        
        let requestResult = await sut.requestLastImageries(decodingType: Int.self)
        
        switch requestResult {
        case .success:
            XCTFail("result should failed with networking error")
        case let .failure(error):
            let error = error as! ServiceError
            XCTAssertTrue(error == .networkingFailure(.badResponse))
        }
    }
    
    func testRequestFilteredImageriesFeedWithValidResponse_ShouldReturn() async {
        arrangeSUTWithMockedNetworkManger(isResponseSuccess: true)
        
        let requestResult = await sut.requestFilteredImageriesFeed(date: .now, cameraType: "FHAZ", decodingType: [String : String].self)
        switch requestResult {
        case .success:
            break
        case .failure:
            XCTFail("result should be equal to success.")
        }
    }
    
    func arrangeSUTWithMockedNetworkManger(isResponseSuccess: Bool) {
        sut = .init(networkManager: MockNetworkManager(isSuccess: isResponseSuccess), roverId: roverId)
    }
}
