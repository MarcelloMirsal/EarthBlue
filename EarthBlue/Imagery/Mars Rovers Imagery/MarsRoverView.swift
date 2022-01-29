//
//  MarsRoverView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import SwiftUI
import Kingfisher

struct MarsRoverView: View {
    let gridItems: [GridItem] = Array.init(repeating: GridItem(.flexible(minimum: 160), spacing: 4), count: 2)
    @StateObject var viewModel: MarsRoverViewModel = .init()
    
    var body: some View {
        List {
            HStack(alignment: .center) {
                Text(viewModel.feedHeaderDateTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(8)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            LazyVGrid(columns: gridItems, spacing: 4, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.cameraTypes, id: \.id) { camera in
                    Section {
                        ForEach(viewModel.imageries(fromCameraType: camera), id: \.id) { imagery in
                            KFImage(URL(string: imagery.imageryURL)!)
                                .placeholder {
                                    Color(uiColor: .lightGray.withAlphaComponent(0.25))
                                }
                                .retry(maxCount: 2, interval: .seconds(2))
                                .cancelOnDisappear(true)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    } header: {
                        HStack(alignment: .center) {
                            Text(camera.name.fullName())
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(4)
                        .background(Colors.systemBackground)
                    }
                    
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .padding(.horizontal, 4)
        }
        .listStyle(PlainListStyle())
        .refreshable(action: {
            await viewModel.refreshFeed()
        })
        .navigationTitle("Curiosity")
        .overlay {
            TaskProgressView()
                .isHidden(viewModel.requestStatus != .loading)
        }
        .alert(isPresented: .init(get: {
            return viewModel.error != nil
        }, set: { _ in
            viewModel.error = nil
        }), content: {
            Alert(title: Text("\(viewModel.error?.localizedDescription ?? "an error occurred")"))
        })
    }
}

struct MarsRoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarsRoverView()
        }
    }
}
