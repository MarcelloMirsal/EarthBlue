//
//  EventsFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/11/2021.
//

import SwiftUI

struct EventsFilteringView: View {
    let viewModel: EventsFilteringViewModel = .init()
    private let defaultFeedFiltering = EventsFilteringBuilder.defaultFeedFiltering
    @Environment(\.presentationMode) var presentationMode
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var isDateRangeActive = true
    @State private var selectedStatus: FeedStatusOptions = .all
    @Binding private(set) var eventsFeedFiltering: EventsFeedFiltering?
    let statusOptions = FeedStatusOptions.allCases
    
    init(eventsFeedFiltering: Binding<EventsFeedFiltering?>) {
        self._eventsFeedFiltering = eventsFeedFiltering
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Form {
                    Section("range") {
                        Toggle("Date range", isOn: .constant(isDateRangeActive))
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
                                Text(status.rawValue).tag(status)
                            }
                        }
                    }
                    
                }
            
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("New Filtered Feed")
                HStack(spacing: 8) {
                    Button("Reset to Defaults") {
                        updateUI(from: viewModel.defaultFeedFiltering)
                    }
                    .buttonStyle(.bordered)
                    Button("Submit") {
                        eventsFeedFiltering = viewModel.dateRangeEventsFiltering(startDate: startDate, endDate: endDate, status: selectedStatus)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .background(Color(.systemGroupedBackground))
                .padding(.bottom)
                .font(.headline)
                .controlSize(.large)
            }
            .onChange(of: startDate, perform: { newValue in
                // updating selected end date whenever start date change
                endDate = startDate
            })
            .onAppear {
                updateUI(from: eventsFeedFiltering ?? viewModel.defaultFeedFiltering)
            }
        }
    }
    
    func updateUI(from feedFiltering: EventsFeedFiltering) {
        if let dateRange = feedFiltering.dateRange {
            isDateRangeActive = true
            startDate = dateRange.lowerBound
            endDate = dateRange.upperBound
            selectedStatus = feedFiltering.status
        }
    }
}

struct EventsFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        let newFeedFiltering = EventsFilteringBuilder().build()
        let configuredFeedFiltering = EventsFilteringBuilder()
            .set(dateRange: .now.addingTimeInterval(-10000000)...Date.now)
            .set(status: .closed)
            .build()
        Group {
            Color.gray
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(newFeedFiltering))
        }
        Group {
            Color.gray
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(configuredFeedFiltering))
        }
    }
}

enum FeedStatusOptions: String, CaseIterable {
    case active
    case closed
    case all
}
