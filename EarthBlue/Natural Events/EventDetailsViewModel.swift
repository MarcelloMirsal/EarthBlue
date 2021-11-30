//
//  EventDetailsViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 22/11/2021.
//

import Foundation
import CoreLocation

class EventDetailsViewModel {
    let event: Event
    init(event: Event) {
        self.event = event
    }
    
    func locationsInfo() -> [EventLocationInfo] {
        let locationsInfo: [[EventLocationInfo]] = event.geometry.map { geoDetails in
            switch geoDetails.coordinates {
            case .pointCoordinates(let pointCoordinate):
                return [EventLocationInfo(date: geoDetails.date, location: .init(coordinate: pointCoordinate))]
            case .polygonCoordinate(let polygonCoordinate):
                return mapPolygonCoordinates(polygonCoordinates: polygonCoordinate, date: geoDetails.date)
            }
        }
        return locationsInfo.flatMap({$0})
    }
    
    func mapPolygonCoordinates(polygonCoordinates: [[[Double]]], date: String) -> [EventLocationInfo] {
        let flattedCoordinates = polygonCoordinates.flatMap({$0})
        return flattedCoordinates.map { coordinate in
            return EventLocationInfo(date: date, location: .init(coordinate: coordinate))
        }
    }
    
    
    
}
