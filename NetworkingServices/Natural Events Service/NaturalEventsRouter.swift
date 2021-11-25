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
    
    func filteredFeedRequest(dateRange: ClosedRange<Date>, forStatus status: EventStatus) -> URLRequest {
        var urlRequestComponent = baseURLComponent
        let startDateValue = stringDateForQuery(from: dateRange.lowerBound)
        let endDateValue = stringDateForQuery(from: dateRange.upperBound)
        urlRequestComponent.queryItems = [
            QueryItem.startDate.queryItem(withValue: startDateValue),
            QueryItem.endDate.queryItem(withValue: endDateValue),
            QueryItem.status.queryItem(withValue: status.rawValue)
        ]
        return .init(url: urlRequestComponent.url!)
    }
    
    func stringDateForQuery(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

public extension NaturalEventsRouter {
    enum QueryItem: String {
        case status
        case days
        case startDate = "start"
        case endDate = "end"
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
    
    enum EventStatus: String {
        case open
        case closed
        case all
    }
}


