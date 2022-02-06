//
//  EPICFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI

struct EPICFilteringView: View {
    @StateObject var viewModel: EPICFilteringViewModel
    @Binding var imageryFiltering: EPICImageryFiltering?
    @Environment(\.dismiss) var dismiss
    
    init(imageryFiltering: Binding<EPICImageryFiltering?>) {
        self._viewModel = .init(wrappedValue: .init(lastImageryFiltering: imageryFiltering.wrappedValue))
        self._imageryFiltering = imageryFiltering
    }
    
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
                Button(action: {
                    viewModel.restDefaults()
                }, label: {
                    Text("Reset defaults")
                        .fontWeight(.semibold)
                })
                    .padding(.bottom, 8)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
                    .listRowBackground(Color.clear)
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
