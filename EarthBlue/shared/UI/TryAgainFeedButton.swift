//
//  TryAgainFeedButton.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 12/02/2022.
//

import SwiftUI

struct TryAgainFeedButton: View {
    var descriptionMessage: String?
    let buttonTitle: String = "Try Again"
    let action: () -> ()
    var body: some View {
        VStack(spacing: 10) {
            Text(descriptionMessage ?? "")
                .foregroundColor(.secondary)
            Button {
                action()
            } label: {
                Label(buttonTitle.capitalized, systemImage: "arrow.clockwise")
            }
        }
    }
}

struct TryAgainFeedButton_Previews: PreviewProvider {
    static var previews: some View {
        TryAgainFeedButton(descriptionMessage: "message", action: {})
    }
}
