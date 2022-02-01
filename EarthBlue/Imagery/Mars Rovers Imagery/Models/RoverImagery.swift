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
    let imageryURL: String
    let earthDate: String
    
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
            }
        }
    }
}

struct RoverInfo {
    let availableCameras: [RoverCamera.CameraName]
    let landingDate: Date
    let lastImageryDate: Date?
    let isActive: Bool
}

struct RoverInfoFactory {
    static func makeCuriosityRoverInfo() -> RoverInfo {
        let cams: [RoverCamera.CameraName] = [ .FHAZ, .RHAZ, .MAST, .CHEMCAM, .MAHLI, .MARDI, .NAVCAM]
        let dateComponents = DateComponents(calendar: .current, timeZone: TimeZone.init(secondsFromGMT: 0), year: 2012, month: 8, day: 6)
        let landingDate = dateComponents.date!
        return .init(availableCameras: cams, landingDate: landingDate, lastImageryDate: nil, isActive: true)
    }
}
