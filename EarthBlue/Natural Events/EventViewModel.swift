//
//  EventViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 13/11/2021.
//

import Foundation
import NetworkingServices

final class EventsViewModel: ObservableObject {
    
    @Published private(set) var eventsFeed: EventsFeed = .init(events: [])
    @Published private(set) var errorMessage: String?
    
    private let naturalEventsService: NaturalEventsServiceProtocol
    init(naturalEventsService: NaturalEventsServiceProtocol = NaturalEventsService()) {
        self.naturalEventsService = naturalEventsService
    }
    
    // MARK: Accessors
    @MainActor
    private func set(eventsFeed: EventsFeed) {
        self.eventsFeed = eventsFeed
    }
    
    @MainActor
    private func set(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    var events: [Event] {
        eventsFeed.events
    }
    
    // MARK: Feed Requests
    func requestDefaultFeed() async {
        let feedRequestResult = await naturalEventsService.defaultEventsFeed(type: EventsFeed.self)
        await handle(feedRequestResult: feedRequestResult)
    }
    
    
    // MARK: handling request results
    @MainActor
    private func handle(feedRequestResult: Result<EventsFeed, Error>) async  {
        switch feedRequestResult {
        case .success(let requestedFeed):
            set(eventsFeed: requestedFeed)
        case .failure(let error):
            set(errorMessage: error.localizedDescription)
            break
        }
    }
}
