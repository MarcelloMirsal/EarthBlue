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
    
    override func requestFilteredFeedByDateRange(feedFiltering: EventsFeedFiltering) async {
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
    
    override func requestFilteredFeedByDateRange(feedFiltering: EventsFeedFiltering) async {
        let feed = EventsFeed(events: mockedEvents.shuffled())
        await set(eventsFeed: feed)
        set(requestStatus: .success)
    }
}

extension Event {
    static let detailedEventMock = try! JSONDecoder().decode(Event.self, from: eventDataWithPointCoordinates)
    static let polygonDetailedEventMock = try! JSONDecoder().decode(Event.self, from: eventDataWithPolygonCoordinates)
    private static let eventDataWithPolygonCoordinates = """
{
    "id": "EONET_259",
    "title": "South America Floods, December 2015-January 2016",
    "description": "In December and January, heavy summer rains swamped this part of South America causing the Uruguay, Paraguay and Parana rivers to swell beyond flood stage.",
    "link": "https://eonet.gsfc.nasa.gov/api/v3/events/EONET_259",
    "closed": "2016-01-22T00:00:00Z",
    "categories": [
        {
            "id": "floods",
            "title": "Floods"
        }
    ],
    "sources": [
        {
            "id": "EO",
            "url": "http://earthobservatory.nasa.gov/NaturalHazards/event.php?id=87350"
        },
        {
            "id": "IDC",
            "url": "https://www.disasterscharter.org/web/guest/-/flood-in-argenti-3"
        }
    ],
    "geometry": [
        {
            "magnitudeValue": null,
            "magnitudeUnit": null,
            "date": "2015-12-28T00:00:00Z",
            "type": "Polygon",
            "coordinates": [
                [
                    [
                        -62.4609375,
                        -36.5147692391751
                    ],
                    [
                        -62.4609375,
                        -26.049694678787944
                    ],
                    [
                        -52.7880859375,
                        -26.049694678787944
                    ],
                    [
                        -52.7880859375,
                        -36.5147692391751
                    ],
                    [
                        -62.4609375,
                        -36.5147692391751
                    ]
                ]
            ]
        }
    ]
}
""".data(using: .utf8)!
    private static let eventDataWithPointCoordinates = """
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
