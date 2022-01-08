//
//  EPICFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI

struct EPICFilteringView: View {
    @StateObject var viewModel = EPICFilteringViewModel()
    @Binding var imageryFiltering: EPICImageryFiltering?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("enhanced images", isOn: $viewModel.isEnhanced)
                } footer: {
                    Text("enhanced images were processed to enhance land features.")
                }
                
                Section {
                    DatePicker("Images date", selection: $viewModel.selectedDate, in: viewModel.datesRange, displayedComponents: .date)
                    
                }
            }
            .disabled(viewModel.availableDates.isEmpty)
            .overlay(content: {
                TaskProgressView()
                    .isHidden(!viewModel.availableDates.isEmpty)
            })
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("reset") {
                        viewModel.restDefaults()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        imageryFiltering = viewModel.imageryFiltering()
                        dismiss()
                    } label : {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Feed Filtering")
        }
    }
}

struct EPICFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        EPICFilteringView(imageryFiltering: .constant(nil))
    }
}

struct EPICImageryFiltering: Equatable {
    let date: Date
    let isEnhanced: Bool
}
