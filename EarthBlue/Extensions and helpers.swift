//
//  Extensions and helpers.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 16/11/2021.
//

import SwiftUI

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}


extension DateFormatter {
    func eventDate(ISO8601StringDate eventDate: String) -> String {
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateAfterMapping = self.date(from: eventDate)!
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        return newDateFormatter.string(from: dateAfterMapping)
    }
}
