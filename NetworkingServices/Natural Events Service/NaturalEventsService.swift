//
//  NaturalEventsService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation

final class NaturalEventsService {
    let networkManager: NetworkManagerProtocol
    private let router = NaturalEventsRouter()
    
    init(networkManager: NetworkManagerProtocol = NetworkManager() ) {
        self.networkManager = networkManager
    }
    
    func eventsFeed<T: Decodable>(type: T.Type) async -> Result<T,Error> {
        let request = router.defaultFeedRequest()
        do {
            let data = try await networkManager.requestData(for: request)
            let decodedObject = try router.parse(data: data, to: type)
            return .success(decodedObject)
        } catch {
            return .failure(error)
        }
    }
}
