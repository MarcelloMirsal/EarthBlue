//
//  EventsViewModelMock.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 16/11/2021.
//

import Foundation


class EventsViewModelMockWithError: EventsViewModel {
    override func requestDefaultFeed() async {
        await handle(feedRequestResult: .failure(URLError(.badURL)))
    }
}

class EventsViewModelMock: EventsViewModel {
    let mockedEvents: [Event] = [ .activeEventMock, .closedEventMock ]
    
    override func requestDefaultFeed() async {
        await handle(feedRequestResult: .success(.init(events: mockedEvents)))
    }
    
}

fileprivate extension Event {
    
    static let activeEventMock = Event(id: "0", title: "Tropical Storm Sandra", closed: nil, categories: [.init(id: "0", title: "Wildfires")], geometry: [.init(date: "2021-11-14T00:00:00Z", coordinates: [1,2])])
    
    static let closedEventMock = Event(id: "1", title: "Iceberg A69C", closed: "2021-11-14T00:00:00Z", categories: [.init(id: "0", title: "Sea and Lake Ice")], geometry: [.init(date: "2021-11-13T00:00:00Z", coordinates: [2,0])])
}


extension Event {
    static let detailedEventMock = try! JSONDecoder().decode(Event.self, from: jsonData)
    private static let jsonData = """
{
            "id": "EONET_5972",
            "title": "Wildfire - SW of Boulder City, Nevada - United States",
            "description": null,
            "link": "https://eonet.gsfc.nasa.gov/api/v3/events/EONET_5972",
            "closed": null,
            "categories": [
                {
                    "id": "wildfires",
                    "title": "Wildfires"
                }
            ],
            "sources": [
                {
                    "id": "PDC",
                    "url": "http://emops.pdc.org/emops/?hazard_id=133260"
                }
            ],
            "geometry": [
                {
                    "magnitudeValue": null,
                    "magnitudeUnit": null,
                    "date": "2021-11-11T20:40:00Z",
                    "type": "Point",
                    "coordinates": [
                        -115.354724564,
                        35.621645413
                    ]
                }
        ]
}
""".data(using: .utf8)!
}
