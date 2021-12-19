//
//  EventMocks.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 24/11/2021.
//

import Foundation

extension Event {
    static let activeEventMock = Event(id: "EONET_5984", title: "Tropical Storm Rai", closed: nil, categories: [.init(id: "severeStorms", title: "Severe Storms")], geometry: [.init(date: "2021-11-14T00:00:00Z", coordinates: .pointCoordinates([139.9, 6]))], sources: [
        .init(id: "JTWC", url: "https://www.metoc.navy.mil/jtwc/products/sh0222.tcw"),
        .init(id: "GDACS", url: "https://www.metoc.navy.mil/jtwc/products/sh0222.tcw"),
    ])
    
    static let closedEventMock = Event(id: "EONET_4123", title: "Iceberg B09I", closed: "2021-11-14T00:00:00Z", categories: [.init(id: "seaLakeIce", title: "Sea and Lake Ice")], geometry: [.init(date: "2021-11-13T00:00:00Z", coordinates: .pointCoordinates([85.49,-65.87]))], sources: [ .init(id: "NATICE", url: "https://usicecenter.gov/pub/Iceberg_Tabular.csv") ])
}


