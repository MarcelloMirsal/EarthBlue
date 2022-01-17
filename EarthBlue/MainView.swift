//
//  MainView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 06/11/2021.
//

import SwiftUI
import Kingfisher
struct MainView: View {
    var body: some View {
        TabView {
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "bell.fill")
                }
            ImageryView()
                .tabItem {
                    Label("Imagery", systemImage: "camera.aperture")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

