//
//  EventViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 13/11/2021.
//

import Foundation
import NetworkingServices

class EventsViewModel: ObservableObject {
    
    @Published var eventsFeed: EventsFeed = .init(events: [])
    @Published var requestStatus: RequestStatus = .loading
    private let naturalEventsService: NaturalEventsServiceProtocol
    var errorMessage: String?
    
    init(naturalEventsService: NaturalEventsServiceProtocol = NaturalEventsService()) {
        self.naturalEventsService = naturalEventsService
    }
    
    // MARK: Accessors
    @MainActor
    private func set(eventsFeed: EventsFeed) {
        self.eventsFeed = eventsFeed
    }
    
    func set(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    func set(requestStatus: RequestStatus) {
        self.requestStatus = requestStatus
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
    
    // MARK: Feed Requests
    func requestDefaultFeed() async {
        print("requestin....")
        set(requestStatus: .loading)
        let feedRequestResult = await naturalEventsService.defaultEventsFeed(type: EventsFeed.self)
        await handle(feedRequestResult: feedRequestResult)
    }
    
    // MARK: Events filtering
    func filteredEvents(withName nameQuery: String) -> [Event] {
        return events.lazy.filter({ $0.title.localizedCaseInsensitiveContains(nameQuery) })
    }
    
    // MARK: handling request results
    @MainActor
     func handle(feedRequestResult: Result<EventsFeed, Error>) async  {
        switch feedRequestResult {
        case .success(let requestedFeed):
            set(eventsFeed: requestedFeed)
            set(requestStatus: .success)
        case .failure(let error):
            set(errorMessage: error.localizedDescription)
            set(requestStatus: .failed)
            break
        }
    }
    
    enum RequestStatus {
        case loading
        case success
        case failed
    }
}
