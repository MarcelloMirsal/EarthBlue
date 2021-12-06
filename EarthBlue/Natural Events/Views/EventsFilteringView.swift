//
//  EventsFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/11/2021.
//

import SwiftUI

struct EventsFilteringView: View {
    var viewModel: EventsFilteringViewModel = .init()
    @Environment(\.presentationMode) var presentationMode
    @State private var isDaysRangeActive = true
    @State private var isDateRangeActive = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var selectedStatus: FeedStatusOptions = .all
    @Binding private(set) var eventsFeedFiltering: EventsFeedFiltering?
    @State var numberOfDays: String = "1"
    var formattedNumberOfDays: String {
        return viewModel.formattedNumberOfDays(fromTextFieldString: numberOfDays)
    }
    @FocusState var isNumberOfDaysFocused: Bool
    let statusOptions = FeedStatusOptions.allCases
    
    init(eventsFeedFiltering: Binding<EventsFeedFiltering?>) {
        self._eventsFeedFiltering = eventsFeedFiltering
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("By Days") {
                        Toggle("Last days", isOn: $isDaysRangeActive)
                            .onChange(of: isDaysRangeActive) { newValue in
                                isDateRangeActive = !newValue
                            }
                        if isDaysRangeActive {
                            TextField("Number of days", text: .init(get: {
                                formattedNumberOfDays
                            }, set: { newValue in
                                numberOfDays = newValue
                            }), prompt: nil)
                                .keyboardType(.numberPad)
                                .focused($isNumberOfDaysFocused)
                                .onChange(of: isNumberOfDaysFocused) { newValue in
                                    guard newValue == false else { return }
                                    if numberOfDays.isEmpty { numberOfDays = "1" }
                                }
                        }
                    }
                    Section("By Date") {
                        Toggle("Date range", isOn: $isDateRangeActive)
                            .onChange(of: isDateRangeActive) { newValue in
                                isDaysRangeActive = !newValue
                            }
                        if isDateRangeActive {
                            DatePicker("start",
                                       selection: $startDate,
                                       in: viewModel.startingDatePickerRange(),
                                       displayedComponents: .date
                            )
                                .onChange(of: startDate) { newValue in
                                    endDate = newValue
                                }
                            DatePicker("end",
                                       selection: $endDate,
                                       in: viewModel.endingDatePickerRange(startDate: startDate),
                                       displayedComponents: .date
                            )
                        }
                    }
                    Section("Status") {
                        Picker("Selected status", selection: $selectedStatus) {
                            ForEach(statusOptions, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                    }
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("New Filtered Feed")
            }
            .toolbar {
                ToolbarItem.init(placement: .navigationBarLeading) {
                    Button("Reset") {
                        updateUI(from: viewModel.defaultFeedFiltering)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                        if isDaysRangeActive {
                            guard let formattedNumberOfDays = Int(formattedNumberOfDays) else { return }
                            eventsFeedFiltering = viewModel.feedFiltering(byDays: formattedNumberOfDays, status: selectedStatus)
                        } else if isDateRangeActive {
                            eventsFeedFiltering = viewModel.dateRangeEventsFiltering(startDate: startDate, endDate: endDate, status: selectedStatus)
                        }
                    }
                }
            }
        }
        .task {
            updateUI(from: eventsFeedFiltering ?? .defaultFiltering)
        }
    }
    
    func updateUI(from feedFiltering: EventsFeedFiltering) {
        switch feedFiltering.filteringType {
        case .days(let days):
            isDaysRangeActive = true
            numberOfDays = "\(days)"
        case .dateRange(let dateRange):
            isDateRangeActive = true
            startDate = dateRange.lowerBound
            endDate = dateRange.upperBound
        }
        selectedStatus = feedFiltering.status
    }
}

struct EventsFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        let datesFeedFiltering = EventsFeedFiltering(status: .active, filteringType: .dateRange( Date()...Date() ))
        let daysFeedFiltering = EventsFeedFiltering.defaultFiltering
        Group {
            Color.gray
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(datesFeedFiltering))
        }
        Group {
            Color.gray
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(daysFeedFiltering))
        }
    }
}

enum FeedStatusOptions: String, CaseIterable {
    case active
    case closed
    case all
}
