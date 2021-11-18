//
//  EventsView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 14/11/2021.
//

import SwiftUI

struct EventsView: View {
    @ObservedObject var viewModel: EventsViewModel
    
    init(viewModel: EventsViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.events, id: \.id) { event in
                    EventRow(event: event)
                }
                .refreshable(action: {
                    await viewModel.requestDefaultFeed()
                })
                .navigationTitle("Events")
                Group {
                    ProgressView("Loading...")
                        .isHidden(!viewModel.shouldShowLoadingIndicator)
                    Text("pull down to refresh")
                        .isHidden(!viewModel.shouldShowPullToRefresh)
                }
                .foregroundColor(.secondary)
            }
        }
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
