//
//  EventDetailsViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 22/11/2021.
//

import Foundation
import CoreLocation
import MapKit

class EventDetailsViewModel {
    let event: Event
    init(event: Event) {
        self.event = event
    }
    
    lazy var locationsInfo: [EventLocationInfo] = getLocationsInfo()
    
    private func getLocationsInfo() -> [EventLocationInfo] {
        let locationsInfo: [[EventLocationInfo]] = event.geometry.map { geoDetails in
        
            let formattedDate = DateFormatter.date(fromISO8601StringDate: geoDetails.date)
            switch geoDetails.coordinates {
            case .pointCoordinates(let pointCoordinate):
                return [EventLocationInfo(date: formattedDate, location: .init(coordinate: pointCoordinate))]
            case .polygonCoordinate(let polygonCoordinate):
                return mapPolygonCoordinates(polygonCoordinates: polygonCoordinate, date: formattedDate)
            }
        }
        return locationsInfo.flatMap({$0}).sorted(by: { lhs, rhs in
            lhs.date < rhs.date
        })
    }
    
    private func mapPolygonCoordinates(polygonCoordinates: [[[Double]]], date: Date) -> [EventLocationInfo] {
        let flattedCoordinates = polygonCoordinates.flatMap({$0})
        return flattedCoordinates.map { coordinate in
            return EventLocationInfo(date: date, location: .init(coordinate: coordinate))
        }
    }
    
    func formattedDate(for locationInfo: EventLocationInfo) -> String {
        return DateFormatter.eventDate(ISO8601Date: locationInfo.date)
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
    
    func mapItem(for coordinate: CLLocationCoordinate2D) -> MKMapItem {
        return .init(placemark: .init(coordinate: coordinate))
    }
    
    func formattedLocationCoordinate(from coordinate: CLLocationCoordinate2D) -> String {
        return "Longitude: \(coordinate.longitude), Latitude: \(coordinate.latitude)"
    }
    
    
}
