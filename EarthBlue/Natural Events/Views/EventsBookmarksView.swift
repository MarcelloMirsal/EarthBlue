//
//  EventsBookmarksView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 14/12/2021.
//

import SwiftUI

struct EventsBookmarksView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = EventsBookmarksViewModel()
    @State private var searchingText: String = ""
    @State private var canShowEventDetails = false
    @State private var isBookmarkDetailsLoading = false
    
    var eventsBookmark: [EventBookmark] {
        return searchingText.isEmpty ? viewModel.eventsBookmark : filteredBookmarks
    }
    
    var filteredBookmarks: [EventBookmark] {
        return viewModel.filteredBookmarks(nameQuery: searchingText)
    }
    
    var isSearching: Bool {
        !searchingText.isEmpty
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(eventsBookmark.sorted(), id: \.id) { bookmark in
                    ZStack(alignment: .leading) {
                        NavigationLink(destination: EventDetailsView(event: viewModel.event), isActive: $canShowEventDetails ) {
                            EmptyView()
                        }
                        .disabled(true)
                        Button(bookmark.title) {
                            Task(priority: .userInitiated) {
                                do {
                                    isBookmarkDetailsLoading = true
                                    try await viewModel.eventDetails(forEventId: bookmark.id)
                                    isBookmarkDetailsLoading = false
                                    canShowEventDetails = true
                                }
                            }
                        }
                    }
                    .swipeActions(content: {
                        Button(role: .destructive) {
                            viewModel.delete(eventBookmark: bookmark)
                        } label: {
                            Image(systemName: "trash")
                        }
                    })
                }
            }
            .disabled(isBookmarkDetailsLoading)
            .toolbar(content: {
                Button("Done") {
                    dismiss()
                }
                .font(.body.bold())
            })
            .listStyle(PlainListStyle())
            .searchable(text: $searchingText,placement: .navigationBarDrawer(displayMode: .always), prompt: "search bookmarks")
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                TaskProgressView()
                    .isHidden(!isBookmarkDetailsLoading, remove: !isBookmarkDetailsLoading)
            }
        }
        .onDisappear {
            viewModel.saveEventsBookmark()
        }
    }
}

struct EventsBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .sheet(isPresented: .constant(true)) {
                EventsBookmarksView()
            }
    }
}


struct TaskProgressView: View {
    var body: some View {
        ProgressView()
            .tint(.primary)
            .padding(18)
            .background(Color(uiColor: .systemFill))
            .cornerRadius(8)
    }
}
