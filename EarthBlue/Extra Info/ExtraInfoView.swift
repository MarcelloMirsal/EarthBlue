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
    @State private var cacheSize: String = ""
    @State private var canPresentCacheDeletionConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(role: .destructive) {
                        canPresentCacheDeletionConfirmation = true
                    } label: {
                        HStack {
                            Text("Clear cache")
                            Spacer()
                            Text(cacheSize)
                        }
                    }
                    .disabled(isClearCacheDisabled)
                    .confirmationDialog("", isPresented: $canPresentCacheDeletionConfirmation) {
                        Button("Clear Cached Images", role: .destructive) {
                            isClearCacheDisabled = true
                            ImageCache.default.clearDiskCache {
                                isClearCacheDisabled = false
                                showCacheClearingMessage = true
                                calculateCacheSize()
                            }
                        }
                    }
                } header: {
                    Text("Storage")
                } footer: {
                    Text("EarthBlue is caching images after been downloaded to avoid re-downloading them when required, Clear cache will delete all images in the cache.")
                }
                
                Section(LocalizedStringKey("about")) {
                    Link("Privacy Policy", destination: .init(string: NSLocalizedString("privacy-policy-link", comment: "privacy policy URL"))!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Extra")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Cache clearing", isPresented: $showCacheClearingMessage) {
            Button("OK") {}
        } message: {
            Text("cache has been cleared.")
        }
        .tabItem {
            Label("Extra", systemImage: "ellipsis")
        }
        .task {
            calculateCacheSize()
        }
    }
    
    func calculateCacheSize() {
        ImageCache.default.calculateDiskStorageSize { result in
            if case .success(let size) = result {
                guard size > 0 else {
                    isClearCacheDisabled = true
                    cacheSize = "0.0 MB"
                    return
                }
                let megabyteFactor = pow(1024.0, 2.0)
                let sizeInMegabytes = Double(size) / megabyteFactor
                cacheSize = String(format: "%.2fMB", sizeInMegabytes)
                isClearCacheDisabled = false
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraInfoView()
    }
}
