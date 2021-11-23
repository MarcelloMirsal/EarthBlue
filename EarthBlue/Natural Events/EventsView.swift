//
//  EventsView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 14/11/2021.
//

import SwiftUI

struct EventsView: View {
    @ObservedObject var viewModel: EventsViewModel
    @State private var searchText: String = ""
    
    init(viewModel: EventsViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                EventsList(searchText: $searchText)
                    .environmentObject(viewModel)
                    .navigationTitle("Events")
                Group {
                    Text("Loading...")
                        .isHidden(!viewModel.shouldShowLoadingIndicator)
                    Text("pull down to refresh")
                        .isHidden(!viewModel.shouldShowPullToRefresh)
                }
                .foregroundColor(.secondary)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for events in this list")
        .alert("Error", isPresented: .init(get: {
            viewModel.shouldPresentError
        }, set: { _ in
            viewModel.set(errorMessage: nil)
        }), actions: {
            Button("Ok") {}
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .task {
            await viewModel.requestDefaultFeed()
        }
    }
    
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventsView(viewModel: EventsViewModelMock())
            EventsView(viewModel: EventsViewModelMockWithError())
        }
        .previewLayout(.sizeThatFits)
    }
}


fileprivate extension EventRow {
    init(event: Event) {
        self.init(title: event.title, category: event.category, lastUpdateData: event.lastUpdatedDate, isActive: event.isActive)
    }
}

fileprivate struct EventsList: View {
    @Environment(\.isSearching) var isSearching: Bool
    @Environment(\.dismissSearch) var dismissSearch
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

