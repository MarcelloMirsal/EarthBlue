//
//  EventLocationInfo.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 23/11/2021.
//

import CoreLocation

struct EventLocationInfo {
    var id: UUID = .init()
    var date: Date
    let location: CLLocationCoordinate2D
}
