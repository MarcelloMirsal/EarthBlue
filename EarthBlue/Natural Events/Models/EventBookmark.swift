//
//  EventBookmark.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 15/12/2021.
//

import Foundation

struct EventBookmark: Comparable, Hashable, Codable {
    let id: String
    let title: String
    
    static func < (lhs: EventBookmark, rhs: EventBookmark) -> Bool {
        return lhs.title < rhs.title
    }
}
