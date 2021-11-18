//
//  NaturalEventsService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation

public protocol NaturalEventsServiceProtocol: AnyObject {
    func defaultEventsFeed<T: Decodable>(type: T.Type) async -> Result<T,Error>
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
        let request = router.defaultFeedRequest()
        do {
            let data = try await networkManager.requestData(for: request)
            let decodedObject = try router.parse(data: data, to: type)
            return .success(decodedObject)
        } catch {
            return .failure( error)
        }
    }
}
