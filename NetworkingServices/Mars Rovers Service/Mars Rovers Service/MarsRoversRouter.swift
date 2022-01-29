//
//  MarsRoversRouter.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/01/2022.
//

import Foundation
struct MarsRoversRouter  {
    let api_key = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
    var baseURL: URL {
        var urlComponents = URLComponents(url: URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers?")!, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            .init(name: QueryItemsKeys.apiKey.rawValue, value: api_key)
        ]
        return urlComponents.url!
    }
    
    func curiosityLastAvailableImagery() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += Paths.curiosityPhotos.rawValue
        var queryItems = urlComponents.queryItems ?? [URLQueryItem]()
        queryItems.insert(.init(name: QueryItemsKeys.earthDate.rawValue, value: twoDaysBeforeNowStringDate()), at: 0)
        queryItems.insert(.init(name: QueryItemsKeys.camera.rawValue, value: "FHAZ"), at: 0)
        urlComponents.queryItems = queryItems
        return .init(url: urlComponents.url!)
    }
    
    func twoDaysBeforeNowStringDate() -> String {
        let twoDaysBeforeDate = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        return dateFormatter.string(from: twoDaysBeforeDate)
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
    }
    
    enum QueryItemsKeys: String {
        case apiKey = "api_key"
        case earthDate = "earth_date"
        case camera = "camera"
    }
}
