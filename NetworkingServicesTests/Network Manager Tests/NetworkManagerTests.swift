//
//  NetworkManagerTests.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 09/11/2021.
//

import XCTest
import Alamofire

@testable import NetworkingServices
class NetworkManagerTests: XCTestCase {
    
    var sut: NetworkManager!
    let fakeURLRequest = URLRequest(url: .init(string: "https://google.com")!)
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let sessionConfigs = URLSessionConfiguration.ephemeral
        sessionConfigs.protocolClasses = [MockURLProtocol.self]
        sut = .init(sessionConfigs: sessionConfigs)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: Testing initializer
    func testDefaultInit_ShouldSetSessionToAlamofireDefaultSession() {
        sut = .init()
        XCTAssertEqual(sut.session.session, AF.session)
    }
    
    func testInitWithSessionConfigs_ShouldSetNewSessionWithThePassedConfigs() {
        let newSessionConfigs = URLSessionConfiguration.ephemeral
        sut = .init(sessionConfigs: newSessionConfigs)
        XCTAssertEqual(sut.session.sessionConfiguration, newSessionConfigs)
    }
    
    // MARK: Testing Requests
    func testRequestDataWithValidDataResponse_ShouldReturnNotNilData() async {
        arrangeSutWithValidDataResponse()
        let data = try? await sut.requestData(for: fakeURLRequest)
        XCTAssertNotNil(data)
    }
    
    func testRequestDataWithInvalidDataResponse_ShouldThrowBadResponseError() async {
        arrangeSutWithFailedDataResponse()
        do {
            let _ = try await sut.requestData(for: fakeURLRequest)
            XCTFail()
        } catch {
            XCTAssertNotNil(error as? URLError)
        }
    }
    
    
    // MARK: SUT arranges
    func arrangeSutWithValidDataResponse() {
        let validData = JSONResponses.validJSONResponse.data(using: .utf8)!
        let mockedRequestHandler = { (request: URLRequest) -> (HTTPURLResponse, Data) in
            return (HTTPURLResponse(), validData)
        }
        MockURLProtocol.requestHandler = mockedRequestHandler
    }
    
    func arrangeSutWithFailedDataResponse() {
        MockURLProtocol.requestHandler = { request throws -> (HTTPURLResponse, Data) in
            throw URLError(.badServerResponse)
        }
    }
}



fileprivate struct JSONResponses {
    static var validJSONResponse: String {
        return """
{
"title": "JSON_String"
}
"""
    }
    
}
