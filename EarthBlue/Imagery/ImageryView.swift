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
                            ImageryTypeView(imageName: "EPICImageThumb", title: "Earth Polychromatic Imaging Camera (EPIC)")
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


struct ImageryTypeView: View {
    let imageName: String
    let title: String
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
            }
            .padding()
        }
    }
}
