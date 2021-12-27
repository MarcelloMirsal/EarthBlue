//
//  EPICFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 26/12/2021.
//

import SwiftUI

struct EPICFilteringView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isEnhanced: Bool = false
    @State private var selectedDate = Date()
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("enhanced images", isOn: $isEnhanced)
                } footer: {
                    Text("enhanced images were processed to enhance land features.")
                }
                
                Section {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    
                }
                
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
        EPICFilteringView()
    }
}
