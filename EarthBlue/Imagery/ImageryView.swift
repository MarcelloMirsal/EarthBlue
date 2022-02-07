//
//  ImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/12/2021.
//

import SwiftUI
import Photos

struct ImageryView: View {
    
    let gridItem = GridItem.init(.adaptive(minimum: 272), spacing: 0)
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [gridItem], alignment: .center, spacing: 0) {
                    Section {
                        NavigationLink {
                            EPICImageryView()
                        } label: {
                            ImageryProviderView(imageName: "EPICImageThumb", providerInfo: ImageryProviderInfoFactory.makeEPICImageryProviderInfo())
                        }
                    } header: {
                        HStack {
                            Text("SATELLITES")
                                .font(.title3.weight(.heavy))
                            Spacer()
                        }
                        .padding(8)
                        .shadow(radius: 8)
                    }
                    Section {
                        NavigationLink {
                            MarsRoverView(roverInfo: RoverInfoFactory.makeCuriosityRoverInfo() )
                        } label: {
                            ImageryProviderView(imageName: "MarsCuriosityRover", providerInfo: ImageryProviderInfoFactory.makeCuriosityRoverInfo())
                        }
                        NavigationLink {
                            MarsRoverView(roverInfo: RoverInfoFactory.makeSpiritRoverInfo() )
                        } label: {
                            ImageryProviderView(imageName: "MarsSpiritAndOpportunityRovers", providerInfo: ImageryProviderInfoFactory.makeSpiritRoverInfo())
                        }
                        NavigationLink {
                            MarsRoverView(roverInfo: RoverInfoFactory.makeOpportunityRoverInfo() )
                        } label: {
                            ImageryProviderView(imageName: "MarsSpiritAndOpportunityRovers", providerInfo: ImageryProviderInfoFactory.makeOpportunityRoverInfo())
                        }
                    } header: {
                        HStack {
                            Text("MARS ROVERS")
                                .font(.title3.weight(.heavy))
                            Spacer()
                        }
                        .padding(8)
                        .shadow(radius: 8)
                    }
                }
            }
            .navigationTitle("Imagery")
            .listStyle(PlainListStyle())
            .task {
                PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: { _ in} )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Label("Imagery", systemImage: "camera.on.rectangle.fill")
        }
    }
}

struct ImageryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageryView()
    }
}


struct ImageryProviderView: View {
    @State private var shouldPresentInfoView = false
    let imageName: String
    let providerInfo: ImageryProviderInfo
    var body: some View {
        ZStack(alignment: .top) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .overlay(
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                )
            HStack(spacing: 8) {
                Text(providerInfo.title)
                    .multilineTextAlignment(.leading)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
                Button {
                    shouldPresentInfoView = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title)
                }
            }
            .padding()
            .sheet(isPresented: $shouldPresentInfoView) {
                ImageryProviderInfoView(providerInfo: providerInfo)
            }
        }
    }
}

struct ImageryProviderInfoView: View {
    @Environment(\.dismiss) var dismiss
    let providerInfo: ImageryProviderInfo
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(providerInfo.description)
                        .textSelection(.enabled)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .listRowSeparator(.hidden)
                        .lineSpacing(0.5)
                    Link("more info...", destination: providerInfo.sourceURL)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle(providerInfo.title)
            .listStyle(PlainListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                    }

                }
            }
        }
        
    }
}
