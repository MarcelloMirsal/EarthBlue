//
//  EventsFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 25/11/2021.
//

import SwiftUI
import Combine

struct EventsFilteringView: View {
    
    @StateObject var viewModel: EventsFilteringViewModel = .init()
    @Environment(\.dismiss) var dismiss
    @State private var isDaysRangeActive = true
    @State private var isDateRangeActive = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    @State private var selectedStatus: FeedStatusOptions = .all
    @Binding private(set) var eventsFeedFiltering: EventsFeedFiltering?
    @State var numberOfDays: String = "1"
    @FocusState var isNumberOfDaysFocused: Bool
    @State var isCategoriesExpanded = false
    let statusOptions = FeedStatusOptions.allCases
    
    var formattedNumberOfDays: String {
        return viewModel.formattedNumberOfDays(fromTextFieldString: numberOfDays)
    }
    
    init(eventsFeedFiltering: Binding<EventsFeedFiltering?>) {
        self._eventsFeedFiltering = eventsFeedFiltering
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(LocalizedStringKey("BY DAYS")) {
                        Toggle("Last days", isOn: $isDaysRangeActive)
                            .onChange(of: isDaysRangeActive) { newValue in
                                isDateRangeActive = !newValue
                            }
                        if isDaysRangeActive {
                            TextField("Number of days", text: .init(get: {
                                return numberOfDays
                            }, set: { newValue in
                                numberOfDays = newValue
                            }), prompt: nil)
                                .focused($isNumberOfDaysFocused)
                                .keyboardType(.asciiCapableNumberPad)
                                .onReceive(Just(numberOfDays)) { val in
                                    guard val != formattedNumberOfDays else { return }
                                    numberOfDays = formattedNumberOfDays
                                }
                        }
                    }
                    Section(LocalizedStringKey("BY DATE")) {
                        Toggle("Date range", isOn: $isDateRangeActive)
                            .onChange(of: isDateRangeActive) { newValue in
                                isDaysRangeActive = !newValue
                            }
                        if isDateRangeActive {
                            DatePicker(LocalizedStringKey("start"),
                                       selection: $startDate,
                                       in: viewModel.startingDatePickerRange(),
                                       displayedComponents: .date
                            )
                                .environment(\.calendar, .init(identifier: .gregorian))
                                .onChange(of: startDate) { newValue in
                                    endDate = newValue
                                }
                            DatePicker(LocalizedStringKey("end"),
                                       selection: $endDate,
                                       in: viewModel.endingDatePickerRange(startDate: startDate),
                                       displayedComponents: .date
                            )
                                .environment(\.calendar, .init(identifier: .gregorian))
                        }
                    }
                    Section(LocalizedStringKey("STATUS")) {
                        Picker("Selected status", selection: $selectedStatus) {
                            ForEach(statusOptions, id: \.self) { status in
                                Text(LocalizedStringKey(status.rawValue)).tag(status)
                            }
                        }
                    }
                    DisclosureGroup("Categories", isExpanded: $isCategoriesExpanded) {
                        List(viewModel.categories, id: \.id) { category in
                            let isCategorySelected = viewModel.isCategorySelected(category: category)
                            CategoryView(title: category.title, isSelected: isCategorySelected)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.handleSelection(forCategory: category)
                                }
                        }
                    }
                    Section {
                        Button("Reset to Defaults") {
                            updateUI(from: viewModel.defaultFeedFiltering)
                        }
                        .font(.body.weight(.semibold))
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("New Filtered Feed")
            .toolbar {
                ToolbarItem.init(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isNumberOfDaysFocused = false
                        if isDaysRangeActive {
                            guard let formattedNumberOfDays = Int(formattedNumberOfDays) else { return }
                            eventsFeedFiltering = viewModel.feedFiltering(byDays: formattedNumberOfDays, status: selectedStatus)
                        } else if isDateRangeActive {
                            eventsFeedFiltering = viewModel.feedFilteringByDateRange(startDate: startDate, endDate: endDate, status: selectedStatus)
                        }
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .onChange(of: isNumberOfDaysFocused) { newValue in
            if isNumberOfDaysFocused == false && numberOfDays.isEmpty {
                numberOfDays = viewModel.daysRange.lowerBound.description
            }
        }
        .interactiveDismissDisabled()
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
        viewModel.setSelectedCategories(byIds: feedFiltering.categories)
        selectedStatus = feedFiltering.status
    }
}

struct EventsFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        let datesFeedFiltering = EventsFeedFiltering(status: .active, filteringType: .dateRange( Date()...Date() ))
        Group {
            Color.gray
        }
        .sheet(isPresented: .constant(true)) {
            EventsFilteringView(eventsFeedFiltering: .constant(datesFeedFiltering))
                .environment(\.locale, .init(identifier: "ar"))
        }
    }
}

enum FeedStatusOptions: String, CaseIterable {
    case active = "active"
    case closed = "closed"
    case all = "all"
}


fileprivate struct CategoryView: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
            Spacer()
            Image(systemName: "checkmark")
                .font(.body.weight(.medium))
                .opacity(isSelected ? 1 : 0)
                .foregroundColor(.blue)
                .controlSize(.small)
        }
    }
}
