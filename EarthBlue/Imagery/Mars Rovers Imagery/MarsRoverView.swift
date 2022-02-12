//
//  MarsRoverView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import SwiftUI
import Kingfisher

struct MarsRoverView: View {
    let gridItems: [GridItem] = Array.init(repeating: GridItem(.adaptive(minimum: 160), spacing: 2), count: 2)
    @StateObject var viewModel: MarsRoversViewModel
    @State var selectedImagery: RoverImagery? = nil
    @State var shouldPresentFilteringView: Bool = false

    init(roverInfo: RoverInfo) {
        self._viewModel = .init(wrappedValue: .init(roverInfo: roverInfo))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack(alignment: .center) {
                    Text(viewModel.feedHeaderDateTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(8)
                LazyVGrid(columns: gridItems, spacing: 2, pinnedViews: [.sectionHeaders]) {
                    ForEach(viewModel.cameraTypes, id: \.name) { camera in
                        Section {
                            ForEach(viewModel.imageries(fromCameraType: camera), id: \.id) { imagery in
                                Button {
                                    selectedImagery = imagery
                                } label: {
                                    KFImage(imagery.secureImageryURL())
                                        .placeholder {
                                            Color(uiColor: .lightGray.withAlphaComponent(0.25))
                                        }
                                        .cancelOnDisappear(true)
                                        .retry(maxCount: 5, interval: .seconds(2))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .border(Color.gray.opacity(0.5), width: 0.5)
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
            }
            .navigationTitle(viewModel.roverName)
            if viewModel.requestStatus == .loading && viewModel.imageryFeed.photos.isEmpty {
                TaskProgressView()
            }
            if viewModel.requestStatus == .failed && viewModel.imageryFeed.photos.isEmpty {
                TryAgainFeedButton(action: {
                    Task {
                        await viewModel.refreshFeed()
                    }
                })
            }
            if viewModel.requestStatus == .success && viewModel.imageryFeed.photos.isEmpty {
                Text("Imageries are not available yet, please try another filtering date.")
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
            ImagePresentationView(imageURL: selectedImagery!.secureImageryURL())
                .ignoresSafeArea()
        }
        .sheet(isPresented: $shouldPresentFilteringView) {
            MarsRoversFilteringView(roverInfo: viewModel.roverInfo, feedFiltering: $viewModel.feedFiltering)
        }
    }
}

struct MarsRoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MarsRoverView(roverInfo: RoverInfoFactory.makeCuriosityRoverInfo())
        }
    }
}
