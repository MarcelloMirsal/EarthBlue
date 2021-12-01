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
    @State private var eventsFeedFiltering: EventsFeedFiltering?
    
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
            .toolbar {
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
        }
        .onChange(of: eventsFeedFiltering, perform: { newValue in
            guard let feedFiltering = newValue else { return }
            Task(priority: .high) {
                canShowFeedFiltering = false
                viewModel.set(feedFiltering: feedFiltering)
                await viewModel.requestFilteredFeedByDateRange(feedFiltering: feedFiltering)
            }
        })
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for events in this feed")
        .alert("Error", isPresented: .init(get: {
            viewModel.shouldPresentError
        }, set: { _ in
            viewModel.set(errorMessage: nil)
        }), actions: {
            Button("Ok") {}
        }, message: {
            Text(viewModel.errorMessage ?? "Unknown error")
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
