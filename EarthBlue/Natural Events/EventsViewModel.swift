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
    @Published private(set) var requestStatus: RequestStatus = .initial
    @Published private(set) var feedFiltering: EventsFeedFiltering?
    @Published private(set) var errorMessage: String?
    private let naturalEventsService: NaturalEventsServiceProtocol
    
    init(naturalEventsService: NaturalEventsServiceProtocol = NaturalEventsService()) {
        self.naturalEventsService = naturalEventsService
        Task {
            await requestDefaultFeed()
        }
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
    
    func set(feedFiltering: EventsFeedFiltering?) {
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
    
    var shouldShowTryAgainButton: Bool {
        return events.isEmpty && requestStatus == .failed
    }
    
    var shouldShowNoEventsFound: Bool {
        return events.isEmpty && requestStatus == .success
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
        await requestFilteredFeed(feedFiltering: feedFiltering)
    }
    
    @MainActor
    func requestDefaultFeed() async {
        if requestStatus != .loading {
            set(requestStatus: .loading)
            set(eventsFeed: .init(events: []))
            let feedRequestResult = await naturalEventsService.defaultEventsFeed(type: EventsFeed.self)
            await handle(feedRequestResult: feedRequestResult)
        }
    }
    
    @MainActor
    func requestFilteredFeed(feedFiltering: EventsFeedFiltering) async {
        if requestStatus != .loading {
            set(eventsFeed: .init(events: []))
            set(requestStatus: .loading)
            let status = map(feedStatusOption: feedFiltering.status)
            let categories = feedFiltering.categories
            let feedRequestResult: Result<EventsFeed, Error>
            switch feedFiltering.filteringType {
            case .days(let days):
                feedRequestResult = await naturalEventsService.filteredEventsFeed(days: days, status: status, categories: categories, type: EventsFeed.self)
            case .dateRange(let dateRange):
                feedRequestResult = await naturalEventsService.filteredEventsFeed(dateRange: dateRange, status: status, categories: categories, type: EventsFeed.self)
            }
            await handle(feedRequestResult: feedRequestResult)
        }
    }
    
    // MARK: Models Mappers
    func map(feedStatusOption: FeedStatusOptions) -> NaturalEventsRouter.EventsStatus {
        switch feedStatusOption {
        case .active:
            return .open
        case .closed:
            return .closed
        case .all:
            return .all
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
}
