//
//  EventRowMocks.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 16/11/2021.
//

import Foundation


extension EventRow {
    static let activeEventMock = EventRow(title: "Tropical Storm Sandra", category: "Severe Storms", lastUpdateData: "Nov 14, 2021 - 12:00 AM", isActive: true)
    
    static let closedEventMock = EventRow(title: "Wildfire - SW of Boulder City, Nevada - United States", category: "Wildfires", lastUpdateData: "Nov 14, 2021 - 12:00 AM", isActive: false)
}
