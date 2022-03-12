//
//  SharedExtensions.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 31/01/2022.
//

import Foundation

extension DateFormatter {
    /// get formatted String date from Date, default format is YYYY-MM-dd
    static func string(from date: Date, stringDateFormat: String = "YYYY-MM-dd", timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = .init(identifier: .gregorian)
        dateFormatter.locale = .init(identifier: "en")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = stringDateFormat
        return dateFormatter.string(from: date)
    }
}
