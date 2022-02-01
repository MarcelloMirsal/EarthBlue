//
//  SharedExtensions.swift
//  NetworkingServices
//
//  Created by Marcello Mirsal on 31/01/2022.
//

import Foundation

extension DateFormatter {
    /// get formatted String date from Date, default format is YYYY-MM-dd
    static func string(from date: Date, stringDateFormat: String = "YYYY-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringDateFormat
        return dateFormatter.string(from: date)
    }
}
