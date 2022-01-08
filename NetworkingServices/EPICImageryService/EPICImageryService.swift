//
//  EPICImageryService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import Foundation

public class EPICImageryService {
    let router = EPICImageryRouter()
    let networkManager: NetworkManagerProtocol
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    public init() {
        self.networkManager = NetworkManager()
    }
    
    public func requestDefaultFeed<T: Decodable>(decodableType: T.Type) async -> Result<T, Error> {
        let urlRequest = router.defaultFeedRequest()
        return await networkRequest(urlRequest: urlRequest, decodingType: decodableType)
    }
    
    public func requestAvailableDates() async -> Result<[String], Error> {
        let availableDateRequest = router.availableDatesRequest()
        return await networkRequest(urlRequest: availableDateRequest, decodingType: [String].self)
    }
    
    public func requestFilteredFeed<T: Decodable>(isImageryEnhanced: Bool, date: Date, decodingType: T.Type) async -> Result<T, Error> {
        let filteredFeedRequest = router.filteredFeedRequest(isImageryEnhanced: isImageryEnhanced, date: date)
        return await networkRequest(urlRequest: filteredFeedRequest, decodingType: T.self)
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
