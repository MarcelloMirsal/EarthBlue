//
//  EPICImageryFiltering.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 12/01/2022.
//

import Foundation

struct EPICImageryFiltering: Equatable {
    let date: Date
    let isEnhanced: Bool
    static var defaultFiltering: Self {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        return .init(date: date, isEnhanced: false)
    }
}
