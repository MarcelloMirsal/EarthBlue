//
//  EventsBookmarkStore.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 15/12/2021.
//

import Foundation

class EventBookmarkStore {
    let filename: String = "EventsBookmarkStore.plist"
    
    var storeFileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
    
    func append(eventBookmark: EventBookmark) {
        let currentBookmarks = readBookmarks()
        let updatedBookmarks = currentBookmarks.union(Set([eventBookmark]))
        write(eventsBookmark: updatedBookmarks)
    }
    
    func write(eventsBookmark: Set<EventBookmark>) {
        let encoder = PropertyListEncoder()
        guard let data = try? encoder.encode(eventsBookmark), let storeFileURL = storeFileURL else {
            return
        }
        try? data.write(to: storeFileURL)
    }
    
    func readBookmarks() -> Set<EventBookmark> {
        let decoder = PropertyListDecoder()
        guard let storeFileURL = storeFileURL, let data = try? Data(contentsOf: storeFileURL) else {
            return []
        }
        let bookmarks = try? decoder.decode(Set<EventBookmark>.self, from: data)
        return bookmarks ?? []
    }
}
