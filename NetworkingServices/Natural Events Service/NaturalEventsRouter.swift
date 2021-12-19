//
//  NaturalEventsRouter.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 11/11/2021.
//

import Foundation

protocol ResponseParser {
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder) throws -> T
}

extension ResponseParser {
    func parse<T: Decodable>(data: Data, to type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        return try decoder.decode(type, from: data)
    }
}

public class NaturalEventsRouter: ResponseParser {
    
    let baseURLComponent = URLComponents(string: "https://eonet.gsfc.nasa.gov/api/v3/events")!
    
    func defaultFeedRequest() -> URLRequest {
        var urlRequestComponent = baseURLComponent
        urlRequestComponent.queryItems = [
            QueryItem.defaultStatus,
            QueryItem.defaultDays
        ]
        return .init(url: urlRequestComponent.url!)
    }
    
    func eventDetailsRequest(eventId: String) -> URLRequest {
        let eventDetailsURL = baseURLComponent.url!.appendingPathComponent(eventId)
        var eventDetailsRequest = URLRequest(url: eventDetailsURL)
        eventDetailsRequest.timeoutInterval = 10
        return eventDetailsRequest
    }
    
    func filteredFeedRequest(days: Int? = nil, dateRange: ClosedRange<Date>? = nil, forStatus status: EventsStatus, categories: [String]? = nil) -> URLRequest {
        var urlRequestComponent = baseURLComponent
        var queryItems = [URLQueryItem]()
        queryItems.append(contentsOf: getQueryItems(from: dateRange))
        if let days = days {
            queryItems.append(QueryItem.days.queryItem(withValue: days.description))
        }
        queryItems.append(QueryItem.status.queryItem(withValue: status.rawValue))
        if let categoriesQuery = getQueryItems(from: categories) {
            queryItems.append(categoriesQuery)
        }
        urlRequestComponent.queryItems = queryItems
        return .init(url: urlRequestComponent.url!)
    }
    
    func stringDateForQuery(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    private func getQueryItems(from dateRange: ClosedRange<Date>?) -> [URLQueryItem] {
        guard let dateRange = dateRange else {return []}
        let startDateValue = stringDateForQuery(from: dateRange.lowerBound)
        let endDateValue = stringDateForQuery(from: dateRange.upperBound)
        return [
            QueryItem.startDate.queryItem(withValue: startDateValue),
            QueryItem.endDate.queryItem(withValue: endDateValue),
        ]
    }
    
    private func getQueryItems(from categories: [String]?) -> URLQueryItem? {
        guard let ids = categories else { return nil}
        let formattedIds = ids.joined(separator: ",") // A,B,C
        return QueryItem.category.queryItem(withValue: formattedIds)
    }
}

public extension NaturalEventsRouter {
    enum QueryItem: String {
        case status
        case days
        case startDate = "start"
        case endDate = "end"
        case category
        func queryItem(withValue value: String) -> URLQueryItem {
            return .init(name: self.rawValue, value: value)
        }
        
        static var defaultStatus: URLQueryItem {
            return Self.status.queryItem(withValue: "all")
        }
        static var defaultDays: URLQueryItem {
            return Self.days.queryItem(withValue: "60")
        }
    }
    
    enum EventsStatus: String {
        case open
        case closed
        case all
    }
}


