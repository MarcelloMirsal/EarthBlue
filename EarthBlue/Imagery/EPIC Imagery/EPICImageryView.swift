//
//  EPICImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI

struct EPICImageryView: View {
    @StateObject var viewModel: EPICImageryViewModel
    @State private var shouldShowFilteringView = false
    init(viewModel: EPICImageryViewModel = .init()) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    var columns: [GridItem] = Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 2) , count: 2)
    
    var body: some View {
        ZStack {
            List {
                LazyVGrid(columns: columns, spacing: 2) {
                    Section {
                        ForEach($viewModel.epicImages) { image in
                            let epicImage = image.wrappedValue.epicImage
                            let url = viewModel.thumbImageURLRequest(for: epicImage).url!
                            EPICImageView(imageURL: url)
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
                await viewModel.requestDefaultFeed()
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
            .sheet(isPresented: $shouldShowFilteringView, content: {
                EPICFilteringView()
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

            if viewModel.isFeedLoading && viewModel.epicImages.isEmpty {
                TaskProgressView()
            }
            if viewModel.isFailedLoading && viewModel.epicImages.isEmpty {
                Text("pull down to refresh")
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
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Image("EPICImageThumb").resizable() // used to set grid item's size while its loading
                            .scaledToFit()
                            .blur(radius: 16, opaque: true)
                            .opacity(0)
                        TaskProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image("EPICImageThumb").resizable() // used to set grid item's size when it is failed.
                        .scaledToFit()
                        .opacity(0)
                        .overlay {
                            Image(systemName: "wifi.exclamationmark")
                        }
                @unknown default:
                    EmptyView()
                }
            }
        }
        .border(Color.gray.opacity(0.5), width: 0.5)
    }
}
