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
                        NavigationLink(destination: EventDetailsView(event: viewModel.eventToShow), isActive: $viewModel.shouldPresentEventDetails) {
                            EmptyView()
                        }
                        .disabled(true)
                        Button(bookmark.title) {
                            viewModel.eventDetails(forEventId: bookmark.id)
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
            .alert(isPresented: .init(get: {
                return viewModel.errorMessage != nil
            }, set: { _ in
                viewModel.errorMessage = nil
            }), content: {
                .init(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: nil)
            })
            .disabled(viewModel.isEventDetailsLoading)
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
                    .isHidden(!viewModel.isEventDetailsLoading, remove: !viewModel.isEventDetailsLoading)
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
