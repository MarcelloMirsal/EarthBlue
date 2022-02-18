//
//  EPICImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI
import Kingfisher

struct EPICImageryView: View {
    @StateObject var viewModel: EPICImageryViewModel = .init()
    @State private var shouldShowFilteringView = false
    @State private var shouldShowImageSliderView = false
    @State private var selectedEPICImage: EPICImageryViewModel.EPICImageIdentifiable?
    
    var columns: [GridItem] = Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 2) , count: 2)
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    Section {
                        ForEach(viewModel.feedImages) { identifiableImage in
                            let url = viewModel.thumbImageURLRequest(for: identifiableImage.epicImage).url!
                            Button {
                                selectedEPICImage = identifiableImage
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
            }
            .navigationTitle("EPIC")
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        shouldShowFilteringView = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .disabled(viewModel.isFeedLoading)
                }
            })
            .fullScreenCover(item: $selectedEPICImage, content: { selectedImage in
                EPICImageSliderView(epicImage: selectedImage.epicImage, isEnhanced: viewModel.epicImagesFeed.isEnhanced)
                    .ignoresSafeArea()
            })
            .sheet(isPresented: $shouldShowFilteringView, content: {
                EPICFilteringView(imageryFiltering: $viewModel.imageryFiltering)
            })
            if viewModel.isFeedLoading && viewModel.epicImagesFeed.epicImages.isEmpty {
                TaskProgressView()
            }
            if viewModel.isFailedLoading && viewModel.epicImagesFeed.epicImages.isEmpty {
                TryAgainFeedButton(descriptionMessage: viewModel.error?.localizedDescription, action: {
                    Task {await viewModel.refreshFeed()}
                })
            }
            if viewModel.isFeedImagesEmpty {
                Text("Imageries are not available yet, please try another filtering options.")
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
        KFImage(imageURL)
            .placeholder({
                Color(uiColor: .lightGray.withAlphaComponent(0.25))
            })
            .cancelOnDisappear(true)
            .retry(maxCount: 5, interval: .seconds(2))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .border(Color.gray.opacity(0.5), width: 0.5)
    }
}
