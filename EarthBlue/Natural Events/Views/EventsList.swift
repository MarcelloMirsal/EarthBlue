//
//  EventsList.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 23/11/2021.
//

import SwiftUI

struct EventsList: View {
    @Environment(\.isSearching) private var isSearching: Bool
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject var viewModel: EventsViewModel
    @Binding var searchText: String
    
    var filteredEvents: [Event] {
        return viewModel.filteredEvents(withName: searchText)
    }
    
    var body: some View {
        List(viewModel.events, id: \.id) { event in
            NavigationLink.init {
                EventDetailsView(event: event)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(event.title)
            } label: {
                EventRow(event: event)
            }
        }
        .refreshable(action: {
            await viewModel.requestDefaultFeed()
        })
        .overlay {
            if isSearching && !searchText.isEmpty {
                EventsSearchResultsList(events: filteredEvents)
                    .background(Colors.systemBackground)
            }
        }
    }
}

fileprivate struct EventsSearchResultsList: View {
    let events: [Event]
    
    var body: some View {
        List(events, id: \.id) { event in
            NavigationLink.init {
                EventDetailsView(event: event)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(event.title)
            } label: {
                EventSearchResultRow(title: event.title, category: event.category)
            }
            
        }
        .listStyle(PlainListStyle())
    }
}

fileprivate struct EventSearchResultRow: View {
    let title: String
    let category: String
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Label {
                Text(title)
                    .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(category)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}

fileprivate extension EventRow {
    init(event: Event) {
        self.init(title: event.title, category: event.category, lastUpdateData: event.lastUpdatedDate, isActive: event.isActive)
    }
}