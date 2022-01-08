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
    private let stringData: String?
    init(isSuccess: Bool, stringData: String? = nil) {
        self.isSuccess = isSuccess
        self.stringData = stringData
    }
    func requestData(for urlRequest: URLRequest) async throws -> Data {
        if isSuccess {
            guard let stringData = stringData else {
                return """
            {
            "title": "JSON_String"
            }
""".data(using: .utf8)!
            }
            return stringData.data(using: .utf8)!
        }
        else { throw NetworkError.badResponse }
    }
}


