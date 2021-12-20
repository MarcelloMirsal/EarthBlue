//
//  EventsBookmarksViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 19/12/2021.
//

import NetworkingServices
import Combine

class EventsBookmarksViewModel: ObservableObject {
    @Published private(set) var eventsBookmark: [EventBookmark]
    @Published private(set) var errorMessage: String?
    let naturalEventsService = NaturalEventsService()
    let eventBookmarkStore: EventBookmarkStore
    var lastLoadedEvent: Event?
    var event: Event {
        return lastLoadedEvent ?? .init(id: "0", title: "", closed: "", categories: [], geometry: [], sources: [])
    }
    init() {
        self.eventsBookmark = []
        self.eventBookmarkStore = .init()
        readBookmarks()
    }
    
    @MainActor
    func set(errorMessage: String?) {
        self.errorMessage = errorMessage
    }
    
    func filteredBookmarks(nameQuery: String) -> [EventBookmark] {
        return eventsBookmark.lazy.filter({ $0.title.localizedCaseInsensitiveContains(nameQuery) })
    }
    
    func delete(eventBookmark: EventBookmark) {
        if let index = eventsBookmark.firstIndex(of: eventBookmark) {
            eventsBookmark.remove(at: index)
        }
    }
    private func readBookmarks() {
        eventsBookmark = Array(eventBookmarkStore.readBookmarks())
    }
    
    func saveEventsBookmark() {
        eventBookmarkStore.write(eventsBookmark: Set(eventsBookmark))
    }
    
    @discardableResult
    func eventDetails(forEventId eventId: String) async throws -> Event {
        let result = await naturalEventsService.eventDetails(eventId: eventId, type: Event.self)
        switch result {
        case .success(let event):
            lastLoadedEvent = event
            return event
        case .failure(let error):
            await set(errorMessage: error.localizedDescription)
            lastLoadedEvent = nil
            throw error
        }
    }
}

