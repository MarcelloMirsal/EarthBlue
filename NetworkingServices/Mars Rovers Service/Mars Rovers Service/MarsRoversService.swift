//
//  MarsRoversService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/01/2022.
//

import Foundation

public class MarsRoversService {
    
    let networkManager: NetworkManagerProtocol
    let router = MarsRoversRouter()
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    public init() {
        self.networkManager = NetworkManager()
    }
    
    public func requestCuriosityLastImagery<T: Decodable>(decodingType: T.Type) async -> Result<T, Error> {
        let lastImageryURLRequest = router.curiosityLastAvailableImagery()
        return await networkRequest(urlRequest: lastImageryURLRequest, decodingType: decodingType)
    }
    
    private func networkRequest<T: Decodable>(urlRequest: URLRequest, decodingType: T.Type) async -> Result<T, Error> {
        do {
            let data = try await networkManager.requestData(for: urlRequest)
            let decodedObject = try router.parse(data: data, to: decodingType)
            return .success(decodedObject)
        } catch let networkError as NetworkError {
            return .failure(ServiceError.networkingFailure(networkError))
        } catch {
            return .failure(ServiceError.decoding)
        }
    }
}