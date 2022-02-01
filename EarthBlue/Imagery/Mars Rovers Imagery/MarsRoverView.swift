//
//  MarsRoverView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import SwiftUI
import Kingfisher

struct MarsRoverView: View {
    let gridItems: [GridItem] = Array.init(repeating: GridItem(.adaptive(minimum: 160), spacing: 4), count: 2)
    @StateObject var viewModel: MarsRoversViewModel = .init()
    @State var selectedImagery: RoverImagery? = nil
    @State var shouldPresentFilteringView: Bool = false
    var body: some View {
        ZStack {
            List {
                HStack(alignment: .center) {
                    Text(viewModel.feedHeaderDateTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(8)
                .listRowSeparator(.hidden)
                LazyVGrid(columns: gridItems, spacing: 4, pinnedViews: [.sectionHeaders]) {
                    ForEach(viewModel.cameraTypes, id: \.name) { camera in
                        Section {
                            ForEach(viewModel.imageries(fromCameraType: camera), id: \.id) { imagery in
                                Button {
                                    selectedImagery = imagery
                                } label: {
                                    KFImage(URL(string: imagery.imageryURL)!)
                                        .placeholder {
                                            Color(uiColor: .lightGray.withAlphaComponent(0.25))
                                        }
                                        .retry(maxCount: 2, interval: .seconds(2))
                                        .cancelOnDisappear(true)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } header: {
                            HStack(alignment: .center) {
                                Text(camera.name.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(4)
                            .background(Colors.systemBackground)
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 4, bottom: 0, trailing: 4))
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Curiosity Rover")
            .refreshable(action: {
                await viewModel.refreshFeed()
            })
            if viewModel.requestStatus == .loading && viewModel.imageryFeed.photos.isEmpty {
                TaskProgressView()
            }
            if viewModel.requestStatus == .failed && viewModel.imageryFeed.photos.isEmpty {
                Text("pull down to refresh")
                    .foregroundColor(.secondary)
            }
            if viewModel.requestStatus == .success && viewModel.imageryFeed.photos.isEmpty {
                Text("Sorry, imageries are not available yet for this date.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .toolbar(content: {
            ToolbarItem {
                Button {
                    shouldPresentFilteringView = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        })
        .alert(isPresented: .init(get: {
            return viewModel.error != nil
        }, set: { _ in
            viewModel.set(error: nil)
        }), content: {
            Alert(title: Text("\(viewModel.error?.localizedDescription ?? "an error occurred")"))
        })
        .fullScreenCover(isPresented: .init(get: {
            return selectedImagery != nil
        }, set: { _ in
            selectedImagery = nil
        }) ) {
            ImagePresentationView(imageURL: .init(string: selectedImagery!.imageryURL)!)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $shouldPresentFilteringView) {
            MarsRoversFilteringView(roverInfo: RoverInfoFactory.makeCuriosityRoverInfo(), feedFiltering: $viewModel.feedFiltering)
        }
    }
}

struct MarsRoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarsRoverView()
        }
    }
}
