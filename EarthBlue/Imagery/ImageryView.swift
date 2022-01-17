//
//  ImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/12/2021.
//

import SwiftUI

struct ImageryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Section {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EPICImageryView()
                        } label: {
                            ImageryProviderView(imageName: "EPICImageThumb", title: "Earth Polychromatic Imaging Camera (EPIC)", providerInfo: ImageryProviderInfoFactory.makeEPICImageryProviderInfo())
                        }
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
            }
            .navigationTitle("Imagery")
            .listStyle(PlainListStyle())
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
    let title: String
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
                Text(title)
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
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .listRowSeparator(.hidden)
                        .lineSpacing(0.5)
                    Link("more info...", destination: providerInfo.sourceURL)
                }
            }
            .navigationTitle(providerInfo.title)
            .listStyle(PlainListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        
    }
}
