//
//  EPICImageryService.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import Foundation

public struct EPICImageryRouter {
    let apiKey: String = "K26yGKzLmYr5Dt8kJSvaz2EC4SHbHE8002rPHV5I"
    let baseURL = URL(string: "https://api.nasa.gov/EPIC/api")!
    let archiveBaseURL = URL(string: "https://epic.gsfc.nasa.gov/archive")!
    public init() {
        
    }
    func defaultFeedRequest() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path += Paths.defaultFeed.rawValue
        urlComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return URLRequest(url: urlComponents.url!)
    }
    
    public func thumbImageRequest(imageName: String, date: Date, isEnhanced: Bool = false) -> URLRequest {
        let imagePathURL = imagePathURL(fromDate: date, imageName: imageName, imageType: .thumb, isEnhanced: isEnhanced)
        var urlComponents = URLComponents(url: imagePathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [ .init(name: QueryItemKeys.apiKey.rawValue, value: apiKey) ]
        return URLRequest(url: urlComponents.url!)
    }
    
    func imagePathURL(fromDate date: Date, imageName: String, imageType: ImageType, isEnhanced: Bool) -> URL {
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
        case thumbImages = "/thumbs"
        case originalImages = "/png"
        case natural = "/natural"
        case enhanced = "/enhanced"
    }
}




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
        do {
            let data = try await networkManager.requestData(for: urlRequest)
            let decodedObject = try router.parse(data: data, to: decodableType)
            return .success(decodedObject)
        } catch let networkError as NetworkError {
            return .failure(ServiceError.networkingFailure(networkError))
        } catch {
            return .failure(ServiceError.decoding)
        }
    }
}
