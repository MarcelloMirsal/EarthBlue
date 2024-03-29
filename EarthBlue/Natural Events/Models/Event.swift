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
    let sources: [EventSource]
}

extension Event: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(closed)
        hasher.combine(categories)
    }
}

extension Event: Equatable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Event {
    var category: String {
        return categories.last?.title ?? ""
    }
    
    var lastUpdatedDate: String {
        guard let closingDate = closed else {
            let lastGeometryUpdateDate = geometry.last!.date
            return DateFormatter.eventDate(ISO8601StringDate: lastGeometryUpdateDate)
        }
        return DateFormatter.eventDate(ISO8601StringDate: closingDate)
    }
    
    var isActive: Bool {
        return closed == nil
    }
}

// MARK: - Category
struct Category: Codable {
    let id, title: String
}

extension Category: Hashable, Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.title < rhs.title
    }
}

extension Category {
    static var defaultCategories: [Category] {
        [
            .init(id: "drought", title: "Drought"),
            .init(id: "dustHaze", title: "Dust and Haze"),
            .init(id: "earthquakes", title: "Earthquakes"),
            .init(id: "floods", title: "Floods"),
            .init(id: "landslides", title: "Landslides"),
            .init(id: "manmade", title: "Manmade"),
            .init(id: "seaLakeIce", title: "Sea and Lake Ice"),
            .init(id: "severeStorms", title: "Severe Storms"),
            .init(id: "snow", title: "Snow"),
            .init(id: "tempExtremes", title: "Temperature Extremes"),
            .init(id: "volcanoes", title: "Volcanoes"),
            .init(id: "waterColor", title: "Water Color"),
            .init(id: "wildfires", title: "Wildfires")
        ]
    }
}


// MARK: - Geometry
struct Geometry: Codable {
    let date: String
    let coordinates: GeoCoordinateType
}

enum GeoCoordinateType: Codable {
    typealias PolygonCoordinates = [[[Double]]]
    typealias PointCoordinates = [Double]
    
    case pointCoordinates(PointCoordinates)
    case polygonCoordinate(PolygonCoordinates)
    
    enum CodingKeys: String, CodingKey {
        case polygonCoordinate
        case pointCoordinates = "coordinates"
    }
    
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else { throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: decoder.codingPath, debugDescription: "", underlyingError: nil)) }
        if let pointCoordinates = try? container.decode(PointCoordinates.self) {
            self = .pointCoordinates(pointCoordinates)
        }
        else if let polygonCoordinates = try? container.decode(PolygonCoordinates.self) {
            self = .polygonCoordinate(polygonCoordinates)
        } else {
            throw DecodingError.valueNotFound(Self.self, .init(codingPath: container.codingPath, debugDescription: "no point or polygon coordinates", underlyingError: nil))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .pointCoordinates(let pointCoordinates):
            try container.encode(pointCoordinates)
        case .polygonCoordinate(let polygonCoordinate):
            try container.encode(polygonCoordinate)
        }
    }
}

// MARK: - EventSource
struct EventSource: Codable {
    let id: String
    let url: String
}
