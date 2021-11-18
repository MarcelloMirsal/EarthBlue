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
    
    static let activeEventMock = Event(id: "0", title: "Tropical Storm Sandra", closed: nil, categories: [.init(id: "0", title: "Wildfires")], geometry: [.init(date: "2021-11-14T00:00:00Z")])
    
    static let closedEventMock = Event(id: "1", title: "Iceberg A69C", closed: "2021-11-14T00:00:00Z", categories: [.init(id: "0", title: "Sea and Lake Ice")], geometry: [.init(date: "2021-11-13T00:00:00Z")])
}

