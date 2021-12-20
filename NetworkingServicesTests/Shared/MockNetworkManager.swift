//
//  MockNetworkManager.swift
//  NetworkingServicesTests
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation
@testable import NetworkingServices

class MockNetworkManager: NetworkManagerProtocol {
    private let isSuccess: Bool
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
    func requestData(for urlRequest: URLRequest) async throws -> Data {
        if isSuccess {
            return """
            {
            "title": "JSON_String"
            }
""".data(using: .utf8)!
        }
        else { throw NetworkError.badResponse }
    }
}


