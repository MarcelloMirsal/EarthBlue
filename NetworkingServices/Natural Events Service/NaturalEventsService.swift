//
//  NaturalEventsService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation

public protocol NaturalEventsServiceProtocol: AnyObject {
    func defaultEventsFeed<T: Decodable>(type: T.Type) async -> Result<T,Error>
    func filteredEventsFeed<T: Decodable>(dateRange: ClosedRange<Date>, status: NaturalEventsRouter.EventStatus ,type: T.Type) async -> Result<T,Error>
}

public final class NaturalEventsService: NaturalEventsServiceProtocol {
    let networkManager: NetworkManagerProtocol
    private let router = NaturalEventsRouter()
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    public init() {
        self.networkManager = NetworkManager()
    }
    
    public func defaultEventsFeed<T: Decodable>(type: T.Type) async -> Result<T,Error> {
        let defaultFeedRequest = router.defaultFeedRequest()
        return await startNetworkRequest(for: defaultFeedRequest, decodingType: T.self)
    }
    
    public func filteredEventsFeed<T: Decodable>(dateRange: ClosedRange<Date>, status: NaturalEventsRouter.EventStatus, type: T.Type) async -> Result<T, Error> {
        let filteredFeedRequest = router.filteredFeedRequest(dateRange: dateRange, forStatus: status)
        return await startNetworkRequest(for: filteredFeedRequest, decodingType: T.self)
    }
    
    private func startNetworkRequest<T: Decodable>(for urlRequest: URLRequest, decodingType: T.Type) async -> Result<T, Error> {
        do {
            let data = try await networkManager.requestData(for: urlRequest)
            let decodedObject = try router.parse(data: data, to: T.self)
            return .success(decodedObject)
        } catch {
            return .failure(error)
        }
    }
}