//
//  EventsFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/11/2021.
//

import SwiftUI

struct EventsFilteringView: View {
    let viewModel: EventsFilteringViewModel = .init()
    @Environment(\.presentationMode) var presentationMode
    @State private var startDate = Date.now
    @State private var endDate = Date.now
    @State private var isDateRangeActive = true
    @State private var selectedStatus: String = "all"
    @Binding private(set) var eventsFeedFiltering: EventsFeedFiltering?
    let statusOptions = ["active", "closed", "all"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("range") {
                        Toggle("Date range", isOn: $isDateRangeActive)
                        if isDateRangeActive {
                            DatePicker("start",
                                       selection: $startDate,
                                       in: viewModel.startingDatePickerRange(),
                                       displayedComponents: .date
                            )
                            DatePicker("end",
                                       selection: $endDate,
                                       in: viewModel.endingDatePickerRange(startDate: startDate),
                                       displayedComponents: .date
                            )
                        }
                    }
                    Section("Status") {
                        Picker("status", selection: $selectedStatus) {
                            ForEach(statusOptions, id: \.self) { status in
                                Text(status).tag(status)
                            }
                        }
                    }
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("New Filtered Feed")
                Button("Submit") {
                    eventsFeedFiltering = viewModel.dateRangeEventsFiltering(startDate: startDate, endDate: endDate, status: selectedStatus)
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                .controlSize(.large)
            }
            .onChange(of: startDate, perform: { newValue in
                // updating selected end date whenever start date change
                endDate = startDate
            })
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct EventsFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        let feedFiltering = EventsFilteringBuilder().build()
        Group {
            Color.red
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(feedFiltering))
        }
    }
}
