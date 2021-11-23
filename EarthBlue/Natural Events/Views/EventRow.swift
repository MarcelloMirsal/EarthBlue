//
//  EventRow.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 16/11/2021.
//

import SwiftUI

struct EventRow: View {
    let title, category, lastUpdateData: String
    let isActive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category)
                .font(.subheadline)
                .fontWeight(.heavy)
            Text(title)
            Text("Last update: \(lastUpdateData)")
                .foregroundColor(.secondary)
                .font(.subheadline)
            EventStatusView(isActive: isActive)
        }
        .padding(4)
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventRow.activeEventMock
            EventRow.closedEventMock
        }
        .previewLayout(.sizeThatFits)
    }
}

fileprivate struct EventStatusView: View {
    @State private var isActive: Bool
    init(isActive: Bool) {
        self.isActive = isActive
    }
    
    var statusColor: Color {
        return isActive ? .red : .green
    }
    
    var body: some View {
        Text(isActive ? "ACTIVE" : "CLOSED")
            .font(.caption)
            .fontWeight(.heavy)
            .foregroundColor(statusColor)
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 3)
                    .foregroundColor(statusColor)
            }
        
    }
}
