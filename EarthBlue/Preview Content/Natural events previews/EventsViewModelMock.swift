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
    let mockedEvents: [Event] = [ .activeEventMock, .closedEventMock, .detailedEventMock ]
    
    override func requestDefaultFeed() async {
        let feed = EventsFeed(events: mockedEvents)
        await set(eventsFeed: feed)
        set(requestStatus: .success)
    }
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
