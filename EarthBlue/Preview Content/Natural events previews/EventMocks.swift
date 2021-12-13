//
//  EventMocks.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 24/11/2021.
//

import Foundation

extension Event {
    static let activeEventMock = Event(id: "0", title: "Tropical Storm Sandra", closed: nil, categories: [.init(id: "0", title: "Wildfires"), .init(id: "1", title: "Temp")], geometry: [.init(date: "2021-11-14T00:00:00Z", coordinates: .pointCoordinates([1,2]))], sources: [
        .init(id: "JTWC", url: "https://www.metoc.navy.mil/jtwc/products/sh0222.tcw"),
        .init(id: "GDACS", url: "https://www.metoc.navy.mil/jtwc/products/sh0222.tcw"),
    ])
    
    static let closedEventMock = Event(id: "1", title: "Iceberg A69C", closed: "2021-11-14T00:00:00Z", categories: [.init(id: "0", title: "Sea and Lake Ice")], geometry: [.init(date: "2021-11-13T00:00:00Z", coordinates: .pointCoordinates([2,0]))], sources: [ .init(id: "A", url: "https://google.com") ])
}


