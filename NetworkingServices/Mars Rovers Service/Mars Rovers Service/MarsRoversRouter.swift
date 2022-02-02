//
//  MarsRoversRouter.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/01/2022.
//


//baseURL
//LastAvailableImagery

import Foundation

struct MarsRoversRouter {
    let apiKey = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
    let baseURL: URL
    let routingStrategy: MarsRoversRouterStrategy
    
    init(roverId: Int) {
        var urlComponents = URLComponents(url: URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers?")!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            .init(name: QueryItemsKeys.apiKey.rawValue, value: apiKey)
        ]
        self.baseURL = urlComponents.url!
        
        switch Rovers(rawValue: roverId)! {
        case .curiosity:
            routingStrategy = CuriosityRoverRoutingStrategy(baseURL: baseURL)
        case .spirit:
            routingStrategy = SpiritRoverRoutingStrategy(baseURL: baseURL)
        }
        
    }
    
    func lastAvailableImagery() -> URLRequest {
        return routingStrategy.lastAvailableImageryRequest()
    }
    
    func filteredImageriesRequest(date: Date, cameraType: String?) -> URLRequest {
        let stringDate = DateFormatter.string(from: date)
        return routingStrategy.filteredImageriesRequest(date: stringDate, cameraType: cameraType)
    }
    
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        do {
            let decodableObject = try decoder.decode(type, from: data)
            return decodableObject
        } catch {
            throw error
        }
    }
    
}

extension MarsRoversRouter {
    enum Paths: String {
        case curiosityPhotos = "/curiosity/photos"
        case spiritPhotos = "/spirit/photos"
    }
    
    enum QueryItemsKeys: String {
        case apiKey = "api_key"
        case earthDate = "earth_date"
        case camera = "camera"
    }
    
    enum Rovers: Int {
        case curiosity = 5
        case spirit = 7
    }
}

protocol MarsRoversRouterStrategy {
    var baseURL: URL { get set }
    var imageriesURLPath: String { get set }
    func lastAvailableImageryRequest() -> URLRequest
    func filteredImageriesRequest(date: String, cameraType: String?) -> URLRequest
}

extension MarsRoversRouterStrategy {
    func filteredImageriesRequest(date: String, cameraType: String?) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += imageriesURLPath
        var queryItems = urlComponents.queryItems ?? []
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.earthDate.rawValue, value: date), at: 0)
        guard let cameraType = cameraType else {
            urlComponents.queryItems = queryItems
            return .init(url: urlComponents.url!)
        }
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.camera.rawValue, value: cameraType), at: 0)
        urlComponents.queryItems = queryItems
        return .init(url: urlComponents.url!)
    }
}

struct CuriosityRoverRoutingStrategy: MarsRoversRouterStrategy {
    var baseURL: URL
    var imageriesURLPath: String = MarsRoversRouter.Paths.curiosityPhotos.rawValue
    
    func lastAvailableImageryRequest() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += imageriesURLPath
        var queryItems = urlComponents.queryItems ?? []
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.earthDate.rawValue, value: twoDaysBeforeNowStringDate()), at: 0)
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.camera.rawValue, value: "FHAZ"), at: 0)
        urlComponents.queryItems = queryItems
        return .init(url: urlComponents.url!)
    }
    
    func twoDaysBeforeNowStringDate() -> String {
        let currentGMTDate = getCurrentGMTDate()
        let gmtTimeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let twoDaysBeforeDate = Calendar.current.date(byAdding: .day, value: -2, to: currentGMTDate)!
        return DateFormatter.string(from: twoDaysBeforeDate, timeZone: gmtTimeZone)
    }
    
    
    private func getCurrentGMTDate() -> Date {
        let date = Date.now
        let sourceOffset = TimeZone.current.secondsFromGMT(for: date)
        let destinationOffset = (TimeZone(secondsFromGMT: 0) ?? .current).secondsFromGMT(for: date)
        let timeInterval = TimeInterval(destinationOffset - sourceOffset)
        return Date(timeInterval: timeInterval, since: date)
    }
}


struct SpiritRoverRoutingStrategy: MarsRoversRouterStrategy {
    var baseURL: URL
    var imageriesURLPath: String = MarsRoversRouter.Paths.spiritPhotos.rawValue
    
    func lastAvailableImageryRequest() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += imageriesURLPath
        var queryItems = urlComponents.queryItems ?? []
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.earthDate.rawValue, value: "2010-01-08"), at: 0)
        queryItems.insert(.init(name: MarsRoversRouter.QueryItemsKeys.camera.rawValue, value: "FHAZ"), at: 0)
        urlComponents.queryItems = queryItems
        return .init(url: urlComponents.url!)
    }
    
}
