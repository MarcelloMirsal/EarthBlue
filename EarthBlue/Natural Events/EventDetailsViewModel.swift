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
            let formattedDate = DateFormatter.eventDate(ISO8601StringDate: geoDetails.date)
            switch geoDetails.coordinates {
            case .pointCoordinates(let pointCoordinate):
                return [EventLocationInfo(date: formattedDate, location: .init(coordinate: pointCoordinate))]
            case .polygonCoordinate(let polygonCoordinate):
                return mapPolygonCoordinates(polygonCoordinates: polygonCoordinate, date: formattedDate)
            }
        }
        return locationsInfo.flatMap({$0})
    }
    
    private func mapPolygonCoordinates(polygonCoordinates: [[[Double]]], date: String) -> [EventLocationInfo] {
        let flattedCoordinates = polygonCoordinates.flatMap({$0})
        return flattedCoordinates.map { coordinate in
            return EventLocationInfo(date: date, location: .init(coordinate: coordinate))
        }
    }
    
    
    func isCoordinatesInPoint() -> Bool? {
        switch event.geometry.first?.coordinates {
        case .pointCoordinates:
            return true
        case .polygonCoordinate:
            return false
        case .none:
            return nil
        }
    }
    
}
