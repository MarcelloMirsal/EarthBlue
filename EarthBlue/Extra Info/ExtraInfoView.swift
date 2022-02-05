//
//  ExtraInfoView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 04/02/2022.
//

import SwiftUI
import Kingfisher

struct ExtraInfoView: View {
    @State private var isClearCacheDisabled = false
    @State private var showCacheClearingMessage = false
    var body: some View {
        NavigationView {
            Form {
                List {
                    Section("Cache") {
                        Button("Clear cache") {
                            isClearCacheDisabled = true
                            ImageCache.default.clearDiskCache {
                                isClearCacheDisabled = false
                                showCacheClearingMessage = true
                            }
                        }
                        .disabled(isClearCacheDisabled)
                    }
                    
                    Section("GENERAL") {
                        NavigationLink("About") {
                            List {
                                Text("EarthBlue is using public APIs to get data for services like natural events, EPIC imagery and mars rovers imageries. these data are provided by NASA, all thanks to NASA's team who made this incredible data available.")
                                    .lineSpacing(4)
                                    .padding(.vertical, 8)
                                    .listRowSeparator(.hidden)
                            }
                            .navigationTitle("About")
                        }
                    }
                }
                .alert("Cache clearing", isPresented: $showCacheClearingMessage) {
                    Button("OK") {}
                } message: {
                    Text("cache has been cleared.")
                        .textCase(nil)
                }
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Label("Extra", systemImage: "ellipsis")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraInfoView()
    }
}
