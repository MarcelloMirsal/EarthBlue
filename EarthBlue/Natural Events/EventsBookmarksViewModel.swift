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
    @Published var shouldPresentEventDetails = false
    @Published var isEventDetailsLoading = false
    @Published var errorMessage: String? = nil
    private(set) var lastLoadedEvent: Event?
    
    private let naturalEventsService = NaturalEventsService()
    private let eventBookmarkStore: EventBookmarkStore
    
    var eventToShow: Event {
        return lastLoadedEvent ?? .init(id: "0", title: "", closed: "", categories: [], geometry: [], sources: [])
    }
    init() {
        self.eventsBookmark = []
        self.eventBookmarkStore = .init()
        readBookmarks()
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
    
    @MainActor
    func eventDetails(forEventId eventId: String) {
        Task(priority: .userInitiated) {
            isEventDetailsLoading = true
            let result = await naturalEventsService.eventDetails(eventId: eventId, type: Event.self)
            switch result {
            case .success(let event):
                handleSuccessLoading(event: event)
                break
            case .failure(let error):
                handleFailure(error: error)
            }
            isEventDetailsLoading = false
        }
    }
    
    @MainActor
    private func handleSuccessLoading(event: Event) {
        lastLoadedEvent = event
        shouldPresentEventDetails = true
    }
    
    @MainActor
    private func handleFailure(error: Error) {
        errorMessage = error.localizedDescription
    }
}

