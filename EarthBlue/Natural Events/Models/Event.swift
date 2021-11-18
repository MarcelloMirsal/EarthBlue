//
//  Event.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 14/11/2021.
//

import Foundation

// MARK: - EventsFeed
struct EventsFeed: Codable {
    let events: [Event]
}


// MARK: - Event
struct Event: Codable {
    let id, title: String
    let closed: String?
    let categories: [Category]
    let geometry: [Geometry]
}

extension Event {
    var category: String {
        return categories.last?.title ?? ""
    }
    
    var lastUpdatedDate: String {
        let dateFormatter = DateFormatter()
        guard let closingDate = closed else {
            let lastGeometryUpdateDate = geometry.last!.date
            return dateFormatter.eventDate(ISO8601StringDate: lastGeometryUpdateDate)
        }
        return dateFormatter.eventDate(ISO8601StringDate: closingDate)
    }
    
    var isActive: Bool {
        return closed == nil
    }
}

// MARK: - Category
struct Category: Codable {
    let id, title: String
}


// MARK: - Geometry
struct Geometry: Codable {
    let date: String
}
