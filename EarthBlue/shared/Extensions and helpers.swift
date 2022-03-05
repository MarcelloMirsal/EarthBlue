//
//  Extensions and helpers.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 16/11/2021.
//

import SwiftUI
import MapKit

public extension CLLocationCoordinate2D {
    init(coordinate: [Double]) {
        self.init(latitude: coordinate.last!, longitude: coordinate.first!)
    }
}

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

extension UIAlertController {
    static func imageAuthNotGrantedAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "can't save image, please grant permission from Settings.", message: nil, preferredStyle: .alert)
        let permissionsSettingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(permissionsSettingsAction)
        alertController.preferredAction = cancelAction
        return alertController
    }
}

extension DateFormatter {
    static func eventDate(ISO8601StringDate eventDate: String) -> String {
        let dateAfterMapping = DateFormatter.date(fromISO8601StringDate: eventDate)
        let newDateFormatter = DateFormatter()
        newDateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        newDateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        return newDateFormatter.string(from: dateAfterMapping)
    }
    
    static func eventDate(ISO8601Date date: Date) -> String {
        let newDateFormatter = DateFormatter()
        newDateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        newDateFormatter.dateFormat = "MMM d, yyyy - h:mm a"
        return newDateFormatter.string(from: date)
    }
    
    static func date(fromISO8601StringDate stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: stringDate)!
    }
    
    /// get Date from string formatted date this formatter is only valid for format = YYYY-MM-dd
    static func date(from stringDate: String, stringDateFormat: String = "YYYY-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringDateFormat
        return dateFormatter.date(from: stringDate)!
    }
}
