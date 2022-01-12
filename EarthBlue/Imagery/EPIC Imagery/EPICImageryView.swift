//
//  EPICImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI
import Kingfisher

struct EPICImageryView: View {
    @StateObject var viewModel: EPICImageryViewModel
    @State private var shouldShowFilteringView = false
    @State private var shouldShowImageSliderView = false
    init(viewModel: EPICImageryViewModel = .init()) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    var columns: [GridItem] = Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 2) , count: 2)
    
    var body: some View {
        ZStack {
            List {
                LazyVGrid(columns: columns, spacing: 2) {
                    Section {
                        ForEach(viewModel.epicImagesFeed.epicImages, id: \.identifier) { epicImage in
                            let url = viewModel.thumbImageURLRequest(for: epicImage).url!
                            Button {
                                shouldShowImageSliderView = true
                            } label: {
                                EPICImageView(imageURL: url)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        HStack {
                            Text(viewModel.feedSectionDate())
                                .font(.title2).fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .ignoresSafeArea(edges: .horizontal)
            .navigationTitle("EPIC")
            .refreshable {
                await viewModel.refreshFeed()
            }
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        shouldShowFilteringView = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            })
            .fullScreenCover(isPresented: $shouldShowImageSliderView, content: {
                EPICImageSliderView(epicImagesFeed: viewModel.epicImagesFeed)
                    .ignoresSafeArea(.all)
            })
            .sheet(isPresented: $shouldShowFilteringView, content: {
                EPICFilteringView(imageryFiltering: $viewModel.imageryFiltering)
            })
            .alert("Error", isPresented: .init(get: {
                return viewModel.error != nil
            }, set: { _ in
                viewModel.set(error: nil)
            })) {
                Button("Ok") {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "an error occurred please try again.")
            }
            if viewModel.isFeedLoading && viewModel.epicImagesFeed.epicImages.isEmpty {
                TaskProgressView()
            }
            if viewModel.isFailedLoading && viewModel.epicImagesFeed.epicImages.isEmpty {
                Text("pull down to refresh")
                    .foregroundColor(.secondary)
            }
            if viewModel.isFeedImagesEmpty {
                Text("Sorry, images are not available yet for this date.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EPICImageryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NavigationLink(isActive: .constant(true)) {
                EPICImageryView()
            } label: {
                Color.gray
            }
        }
    }
}


struct EPICImageView: View {
    let imageURL: URL
    var body: some View {
        VStack(spacing: 0) {
            KFImage(imageURL)
                .onFailureImage(KFCrossPlatformImage.init(systemName: "wifi.exclamationmark"))
                .placeholder {
                    Image("EPICImageThumb").resizable() // used to set grid item's size while its loading
                        .scaledToFit()
                        .blur(radius: 16, opaque: true)
                        .opacity(0)
                    TaskProgressView()
                }
                .fade(duration: 0.25)
                .resizable()
                .scaledToFit()
        }
        .border(Color.gray.opacity(0.5), width: 0.5)
    }
}
