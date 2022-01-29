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
struct RoverCamera: Codable {
    let id: Int
    let name: CameraName
    enum CameraName: String, Codable {
        case CHEMCAM
        case FHAZ
        case MAHLI
        case MAST
        case NAVCAM
        case RHAZ
        
        func fullName() -> String {
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
            }
        }
    }
}
