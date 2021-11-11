//
//  NetworkManager.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 09/11/2021.
//

import Foundation
import Alamofire


protocol NetworkManagerProtocol: AnyObject {
    func requestData(for urlRequest: URLRequest) async throws -> Data
}

/// a wrapper for Alamofire dependency, used to make network requests and validating it.
final class NetworkManager: NetworkManagerProtocol {
    let session: Alamofire.Session
    
    init(sessionConfigs: URLSessionConfiguration = AF.sessionConfiguration) {
        if sessionConfigs == AF.sessionConfiguration {
            self.session = AF
        } else {
            self.session = Alamofire.Session(configuration: sessionConfigs)
        }
    }
    
    func requestData(for urlRequest: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation({ continuation in
            session.request(urlRequest).validate().responseData { dataResponse in
                switch dataResponse.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let afError):
                    let mappedError = afError.underlyingError as! URLError
                    continuation.resume(throwing: mappedError)
                }
            }
        })
    }
    
}
