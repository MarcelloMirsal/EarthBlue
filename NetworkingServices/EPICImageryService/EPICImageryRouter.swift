//
//  EPICImageryRouter.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 01/01/2022.
//

import Foundation

public struct EPICImageryRouter {
    let apiKey: String = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
    let baseURL = URL(string: "https://api.nasa.gov/EPIC/api")!
    let archiveBaseURL = URL(string: "https://epic.gsfc.nasa.gov/archive")!
    public init() {
        
    }
    
    public func defaultFeedRequest() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += Paths.defaultFeed.rawValue
        urlComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return URLRequest(url: urlComponents.url!)
    }
    
    public func filteredFeedRequest(isImageryEnhanced: Bool, date: Date) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy-MM-dd"
        let imageRootPath = dateFormatter.string(from: date)
        let path = isImageryEnhanced ? Paths.enhancedFiltered.rawValue : Paths.naturalFiltered.rawValue
        urlComponents.path += path + imageRootPath
        urlComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return URLRequest(url: urlComponents.url!)
    }
    
    public func thumbImageRequest(imageName: String, stringDate: String, isEnhanced: Bool = false) -> URLRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let imageDate = dateFormatter.date(from: stringDate)!
        let imagePathURL = imagePathURL(fromDate: imageDate, imageName: imageName, imageType: .thumb, isEnhanced: isEnhanced)
        var urlComponents = URLComponents(url: imagePathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return URLRequest(url: urlComponents.url!)
    }
    
    private func imagePathURL(fromDate date: Date, imageName: String, imageType: ImageType, isEnhanced: Bool) -> URL {
        var archiveBaseURL = self.archiveBaseURL
        archiveBaseURL.appendPathComponent(isEnhanced ? Paths.enhanced.rawValue : Paths.natural.rawValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let imageRootPath = dateFormatter.string(from: date)
        archiveBaseURL.appendPathComponent(imageRootPath)
        
        archiveBaseURL.appendPathComponent(imageType == .thumb ? Paths.thumbImages.rawValue : Paths.originalImages.rawValue)
        
        archiveBaseURL.appendPathComponent(imageName)
        switch imageType {
        case .thumb:
            archiveBaseURL.appendPathExtension("jpg")
        case .original:
            archiveBaseURL.appendPathExtension("png")
        }
        return archiveBaseURL
    }
    
    func availableDatesRequest() -> URLRequest {
        var availableDatesURL = baseURL
        availableDatesURL.appendPathComponent(Paths.naturalDates.rawValue)
        var availableDatesURLComponents = URLComponents(url: availableDatesURL, resolvingAgainstBaseURL: true)!
        availableDatesURLComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return .init(url: availableDatesURLComponents.url!)
    }
    
    
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        do {
            let decodableObject = try decoder.decode(type, from: data)
            return decodableObject
        } catch {
            throw error
        }
    }
    
    enum ImageType {
        case thumb
        case original
    }
    
    private enum QueryItemKeys: String {
        case apiKey = "api_key"
    }
    
    private enum Paths: String {
        case defaultFeed = "/natural/images"
        case naturalFiltered = "/natural/date"
        case enhancedFiltered = "/enhanced/date"
        case thumbImages = "/thumbs"
        case originalImages = "/png"
        case natural = "/natural"
        case enhanced = "/enhanced"
        case naturalDates = "/natural/available"
    }
}
