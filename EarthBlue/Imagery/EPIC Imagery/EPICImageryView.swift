//
//  EPICImageryView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI

struct EPICImageryView: View {
    @State private var shouldShowFilteringView = false
    let columns: [GridItem] = [
        .init(.flexible(minimum: 100), spacing: nil),
        .init(.flexible(minimum: 100), spacing: nil)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                Section {
                    ForEach(1...11, id: \.self) { _ in
                        Image("EPICImageThumb")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .border(Color.gray.opacity(0.5), width: 0.25)
                    }
                }
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
            .navigationTitle("EPIC")
            .background(.black)
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
