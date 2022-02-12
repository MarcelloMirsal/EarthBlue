//
//  TryAgainFeedButton.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 12/02/2022.
//

import SwiftUI

struct TryAgainFeedButton: View {
    let title: String = "Try Again"
    let action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Label(title.capitalized, systemImage: "arrow.clockwise")
        }
    }
}

struct TryAgainFeedButton_Previews: PreviewProvider {
    static var previews: some View {
        TryAgainFeedButton(action: {})
    }
}
