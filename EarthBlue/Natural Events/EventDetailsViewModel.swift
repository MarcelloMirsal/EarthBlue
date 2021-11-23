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
        return event.geometry.map({
            let date = DateFormatter().eventDate(ISO8601StringDate: $0.date)
            let locationCoordinate = CLLocationCoordinate2D(coordinate: $0.coordinates)
            return EventLocationInfo(date: date, location: locationCoordinate)
        })
    }
}


struct EventLocationInfo {
    var id: UUID = .init()
    var date: String
    let location: CLLocationCoordinate2D
}
