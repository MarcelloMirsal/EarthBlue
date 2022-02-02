//
//  MarsRoversService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/01/2022.
//

import Foundation

public class MarsRoversService {
    let networkManager: NetworkManagerProtocol
    let router: MarsRoversRouter
    
    init(networkManager: NetworkManagerProtocol = NetworkManager(), roverId: Int) {
        self.networkManager = networkManager
        self.router = .init(roverId: roverId)
    }
    
    public init(roverId: Int) {
        self.networkManager = NetworkManager()
        self.router = .init(roverId: roverId)
    }
    
    public func requestLastImageries<T: Decodable>(decodingType: T.Type) async -> Result<T, Error> {
        let lastImageryURLRequest = router.lastAvailableImagery()
        return await networkRequest(urlRequest: lastImageryURLRequest, decodingType: decodingType)
    }
    
    public func requestFilteredImageriesFeed<T: Decodable>(date: Date, cameraType: String?, decodingType: T.Type) async -> Result<T, Error> {
        let request = router.filteredImageriesRequest(date: date, cameraType: cameraType)
        return await networkRequest(urlRequest: request, decodingType: decodingType)
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
