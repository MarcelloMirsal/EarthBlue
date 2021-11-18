//
//  NaturalEventsRouter.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation

protocol ResponseParser {
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder) throws -> T 
}

extension ResponseParser {
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        return try decoder.decode(type, from: data)
    }
}

class NaturalEventsRouter: ResponseParser {
    private let timeInterval: Double = 10.0
    let baseURLComponent = URLComponents(string: "https://eonet.gsfc.nasa.gov/api/v3/events")!
    
    func defaultFeedRequest() -> URLRequest {
        var urlRequestComponent = baseURLComponent
        urlRequestComponent.queryItems = [
            QueryItem.defaultStatus,
            QueryItem.defaultDays
        ]
        return .init(url: urlRequestComponent.url!, timeoutInterval: timeInterval)
    }
}

extension NaturalEventsRouter {
    enum QueryItem: String {
        case status
        case days
        func queryItem(withValue value: String) -> URLQueryItem {
            return .init(name: self.rawValue, value: value)
        }
        
        static var defaultStatus: URLQueryItem {
            return Self.status.queryItem(withValue: "all")
        }
        static var defaultDays: URLQueryItem {
            return Self.days.queryItem(withValue: "60")
        }
    }
}


