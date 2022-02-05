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
    @State private var canShowFeedFiltering = false
    @State private var canShowBookmarkedEvents = false
    @State private var eventsFeedFiltering: EventsFeedFiltering?
    @State var selectedBookmarkedEvent: Event? = nil
    
    init(viewModel: EventsViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: .init(get: {
                    return selectedBookmarkedEvent != nil
                }, set: { _ in
                    selectedBookmarkedEvent = nil
                })) {
                    EventDetailsView(event: selectedBookmarkedEvent ?? .activeEventMock)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(selectedBookmarkedEvent?.title ?? "")
                } label: {
                    EmptyView()
                }
                
                EventsList(searchText: $searchText)
                    .environmentObject(viewModel)
                    .navigationTitle("Events")
                Group {
                    TaskProgressView()
                        .isHidden(!viewModel.shouldShowLoadingIndicator)
                    Text("Pull down to refresh.")
                        .isHidden(!viewModel.shouldShowPullToRefresh)
                    Text("No events found, try another feed filtering options.")
                        .multilineTextAlignment(.center)
                        .isHidden(!viewModel.shouldShowNoEventsFound)
                }
                .foregroundColor(.secondary)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        canShowBookmarkedEvents = true
                    } label: {
                        Label("", systemImage: "book")
                    }
                    .sheet(isPresented: $canShowBookmarkedEvents) {
                        EventsBookmarksView(selectedBookmarkEvent: $selectedBookmarkedEvent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        canShowFeedFiltering = true
                    } label: {
                        Label("", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .disabled(!viewModel.isFilteringEnabled)
                    .sheet(isPresented: $canShowFeedFiltering) {
                        EventsFilteringView(eventsFeedFiltering: $eventsFeedFiltering)
                    }
                }
            }
            .alert("Error", isPresented: .init(get: {
                viewModel.shouldPresentError
            }, set: { _ in
                viewModel.set(errorMessage: nil)
            }), actions: {
                Button("Ok") {}
            }, message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: eventsFeedFiltering, perform: { newValue in
            Task(priority: .high) {
                canShowFeedFiltering = false
                viewModel.set(feedFiltering: newValue)
                await viewModel.refreshEventsFeed()
            }
        })
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for events in this feed")
        .tabItem {
            Label("Events", systemImage: "bell.fill")
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
