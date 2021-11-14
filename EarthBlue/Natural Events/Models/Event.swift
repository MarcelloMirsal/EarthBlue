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
}

// MARK: - Category
struct Category: Codable {
    let id, title: String
}
