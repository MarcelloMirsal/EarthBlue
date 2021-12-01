//
//  EventViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 13/11/2021.
//

import Foundation
import NetworkingServices

class EventsViewModel: ObservableObject {
    @Published private(set) var eventsFeed: EventsFeed = .init(events: [])
    @Published private(set) var requestStatus: RequestStatus = .success
    @Published private(set) var feedFiltering: EventsFeedFiltering?
    private let naturalEventsService: NaturalEventsServiceProtocol
    private(set) var errorMessage: String?
    
    init(naturalEventsService: NaturalEventsServiceProtocol = NaturalEventsService()) {
        self.naturalEventsService = naturalEventsService
    }
    
    // MARK: Accessors
    @MainActor
    func set(eventsFeed: EventsFeed) {
        self.eventsFeed = eventsFeed
    }
    
    func set(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    func set(requestStatus: RequestStatus) {
        self.requestStatus = requestStatus
    }
    
    func set(feedFiltering: EventsFeedFiltering) {
        self.feedFiltering = feedFiltering
    }
    
    var events: [Event] {
        eventsFeed.events
    }
    
    var shouldPresentError: Bool {
        return errorMessage != nil
    }
    
    var shouldShowLoadingIndicator: Bool {
        return events.isEmpty && requestStatus == .loading
    }
    
    var shouldShowPullToRefresh: Bool {
        return events.isEmpty && requestStatus == .failed
    }
    
    var isFilteringEnabled: Bool {
        return requestStatus != .loading
    }
    
    // MARK: Feed Requests
    func refreshEventsFeed() async {
        guard let feedFiltering = self.feedFiltering else {
            await requestDefaultFeed()
            return
        }
        await requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
    }
    
    func requestDefaultFeed() async {
        if requestStatus != .loading {
            await set(eventsFeed: .init(events: []))
            set(requestStatus: .loading)
            let feedRequestResult = await naturalEventsService.defaultEventsFeed(type: EventsFeed.self)
            await handle(feedRequestResult: feedRequestResult)
        }
    }
    
    func requestFilteredFeedByDateRange(feedFiltering: EventsFeedFiltering) async {
        if requestStatus != .loading {
            guard let dateRange = feedFiltering.dateRange, let status = NaturalEventsRouter.EventStatus(rawValue: feedFiltering.status) else {
                return
            }
            await set(eventsFeed: .init(events: []))
            set(requestStatus: .loading)
            let feedRequestResult = await naturalEventsService.filteredEventsFeed(dateRange: dateRange, status: status, type: EventsFeed.self)
            await handle(feedRequestResult: feedRequestResult)
        }
    }
    
    
    
    // MARK: Events filtering
    func filteredEvents(withName nameQuery: String) -> [Event] {
        return events.lazy.filter({ $0.title.localizedCaseInsensitiveContains(nameQuery) })
    }
    
    // MARK: Handling request results
    @MainActor
    func handle(feedRequestResult: Result<EventsFeed, Error>) async  {
        switch feedRequestResult {
        case .success(let requestedFeed):
            set(eventsFeed: requestedFeed)
            set(requestStatus: .success)
        case .failure(let error):
            set(errorMessage: error.localizedDescription)
            set(requestStatus: .failed)
        }
    }
    
    enum RequestStatus {
        case loading
        case success
        case failed
    }
}
