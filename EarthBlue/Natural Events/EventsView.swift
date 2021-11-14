//
//  EventsView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 14/11/2021.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()
    var body: some View {
        NavigationView {
            List(viewModel.events, id: \.id) { event in
                Text(event.title)
            }
            .navigationTitle("Events")
        }
        .task {
            await viewModel.requestDefaultFeed()
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
