//
//  MainView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 06/11/2021.
//

import SwiftUI
struct MainView: View {
    var body: some View {
        TabView {
            EventsView()
            ImageryView()
            ExtraInfoView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

