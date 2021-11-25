//
//  Mocks.swift
//  EarthBlueTests
//
//  Created by Marcello Mirsal on 14/11/2021.
//

import Foundation
@testable import NetworkingServices

class MockNaturalEventsService: NaturalEventsServiceProtocol {
    func filteredEventsFeed<T: Decodable>(dateRange: ClosedRange<Date>, status: NaturalEventsRouter.EventStatus, type: T.Type) async -> Result<T, Error> {
        return .failure(URLError.init(.badServerResponse))
    }
    
    private let isSuccessResponse: Bool
    init(isSuccessResponse: Bool) {
        self.isSuccessResponse = isSuccessResponse
    }
    func defaultEventsFeed<T>(type: T.Type) async -> Result<T, Error> where T : Decodable {
        guard isSuccessResponse else {
            return .failure(URLError(.badServerResponse) )
        }
        guard let decodedObject = try? JSONDecoder().decode(type.self, from: successResponseData) else {
            fatalError()
        }
        return .success(decodedObject)
    }
    
    var successResponseData: Data {
        """
{
    "title": "EONET Events",
    "description": "Natural events from EONET.",
    "link": "https://eonet.sci.gsfc.nasa.gov/api/v3/events",
    "events": [
        {
            "id": "EONET_2880",
            "title": "Iceberg A64",
            "description": null,
            "link": "https://eonet.sci.gsfc.nasa.gov/api/v3/events/EONET_2880",
            "closed": null,
            "categories": [
                {
                    "id": "seaLakeIce",
                    "title": "Sea and Lake Ice"
                }
            ],
            "sources": [
                {
                    "id": "BYU_ICE",
                    "url": "http://www.scp.byu.edu/data/iceberg/ascat/a64.ascat"
                },
                {
                    "id": "NATICE",
                    "url": "https://usicecenter.gov/pub/Iceberg_Tabular.csv"
                }
            ],
            "geometry": [
                {
                    "magnitudeValue": null,
                    "magnitudeUnit": null,
                    "date": "2014-07-23T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -61.0599,
                        -69.3447
                    ]
                },
                {
                    "magnitudeValue": null,
                    "magnitudeUnit": null,
                    "date": "2015-12-08T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -60.0583,
                        -69.7197
                    ]
                },
                {
                    "magnitudeValue": 117.00,
                    "magnitudeUnit": "NM^2",
                    "date": "2021-02-19T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -60.64,
                        -69.24
                    ]
                },
                {
                    "magnitudeValue": 96.00,
                    "magnitudeUnit": "NM^2",
                    "date": "2021-03-05T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -60.48,
                        -68.64
                    ]
                },
                {
                    "magnitudeValue": 96.00,
                    "magnitudeUnit": "NM^2",
                    "date": "2021-04-16T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -60.95,
                        -68.21
                    ]
                },
                {
                    "magnitudeValue": 88.00,
                    "magnitudeUnit": "NM^2",
                    "date": "2021-06-04T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -61.20,
                        -67.71
                    ]
                },
                {
                    "magnitudeValue": 88.00,
                    "magnitudeUnit": "NM^2",
                    "date": "2021-11-12T00:00:00Z",
                    "type": "Point",
                    "coordinates": [
                        -60.54,
                        -67.25
                    ]
                }
            ]
        }
    ]
}
""".data(using: .utf8)!
    }
}
