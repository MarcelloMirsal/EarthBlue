//
//  RoverImagery.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import Foundation


// MARK: - RoverImageryFeed
struct RoverImageryFeed: Codable {
    let photos: [RoverImagery]
}

// MARK: - RoverImagery
struct RoverImagery: Codable {
    let id: Int
    let camera: RoverCamera
    private let imageryURL: String
    let earthDate: String
    
    /// some imageries providers are old and the API is still using http, this method will return URL with  https scheme
    func secureImageryURL() -> URL {
        var urlComponents = URLComponents(string: imageryURL)!
        urlComponents.scheme = "https"
        return urlComponents.url!
    }
    
    enum CodingKeys: String, CodingKey {
        case id, camera
        case imageryURL = "img_src"
        case earthDate = "earth_date"
    }
}

// MARK: - Camera
struct RoverCamera: Codable, Hashable {
    let id: Int
    let name: CameraName
    
    enum CameraName: String, Codable {
        case FHAZ
        case RHAZ
        case MAST
        case CHEMCAM
        case MAHLI
        case MARDI
        case NAVCAM
        case PANCAM
        case MINITES
        case ENTRY
        
        var fullName: String {
            switch self {
            case .CHEMCAM:
                return "Chemistry and Camera Complex"
            case .FHAZ:
                return "Front Hazard Avoidance Camera"
            case .MAHLI:
                return "Mars Hand Lens Imager"
            case .MAST:
                return "Mast Camera"
            case .NAVCAM:
                return "Navigation Camera"
            case .RHAZ:
                return "Rear Hazard Avoidance Camera"
            case .MARDI:
                return "Mars Descent Imager"
            case .PANCAM:
                return "Panoramic Camera"
            case .MINITES:
                return "Miniature Thermal Emission Spectrometer (Mini-TES)"
            case .ENTRY:
                return "Entry, Descent, and Landing Camera"
            }
        }
    }
}

struct RoverInfo {
    let id: Int
    let name: String
    let availableCameras: [RoverCamera.CameraName]
    let firstImageriesDate: Date
    let lastImageriesDate: Date?
}

struct RoverInfoFactory {
    static func makeCuriosityRoverInfo() -> RoverInfo {
        let cams: [RoverCamera.CameraName] = [ .FHAZ, .RHAZ, .MAST, .CHEMCAM, .MAHLI, .MARDI, .NAVCAM]
        let dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2012, month: 8, day: 6)
        let firstImageriesDate = dateComponents.date!
        
        return .init(id: 5, name: "Curiosity Rover", availableCameras: cams, firstImageriesDate: firstImageriesDate, lastImageriesDate:  nil)
    }
    
    static func makeSpiritRoverInfo() -> RoverInfo {
        let cams: [RoverCamera.CameraName] = [ .FHAZ, .RHAZ, .NAVCAM, .PANCAM, .MINITES]
        var dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2004, month: 1, day: 5)
        let firstImageriesDate = dateComponents.date!
        
        dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2010, month: 3, day: 21)
        let lastUpdateDate = dateComponents.date!
        
        return .init(id: 7, name: "Spirit Rover", availableCameras: cams, firstImageriesDate: firstImageriesDate, lastImageriesDate: lastUpdateDate)
    }
    
    static func makeOpportunityRoverInfo() -> RoverInfo {
        let cams: [RoverCamera.CameraName] = [ .FHAZ, .RHAZ, .NAVCAM, .PANCAM, .MINITES]
        var dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2004, month: 1, day: 26)
        let firstImageriesDate = dateComponents.date!
        
        dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2018, month: 6, day: 11)
        let lastUpdateDate = dateComponents.date!
        
        return .init(id: 6, name: "Opportunity Rover", availableCameras: cams, firstImageriesDate: firstImageriesDate, lastImageriesDate: lastUpdateDate)
    }
}
