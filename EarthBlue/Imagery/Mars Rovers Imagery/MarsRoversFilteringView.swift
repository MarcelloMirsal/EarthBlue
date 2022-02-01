//
//  MarsRoversFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 30/01/2022.
//

import SwiftUI

struct MarsRoversFilteringView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: MarsRoversFilteringViewModel
    @State var isCamerasListExpanded = false
    @Binding var feedFiltering: RoverImageryFeedFiltering?
    
    init(roverInfo: RoverInfo, feedFiltering: Binding<RoverImageryFeedFiltering?> ) {
        let viewModel = MarsRoversFilteringViewModel(roverInfo: roverInfo)
        self._viewModel = .init(wrappedValue: viewModel)
        self._feedFiltering = feedFiltering
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Imageries date", selection: $viewModel.selectedDate, in: viewModel.filteringDateRange, displayedComponents: .date)
                }
                Section {
                    DisclosureGroup(isExpanded: $isCamerasListExpanded) {
                        List(viewModel.roverCameras, id: \.self) { cameraName in
                            Button( action: {
                                viewModel.select(cameraName: cameraName)
                            }, label: {
                                HStack {
                                    Text(cameraName.fullName)
                                        .padding(.vertical, 8)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .font(.body.weight(.medium))
                                        .opacity(viewModel.isCameraNameSelected(cameraName: cameraName) ? 1 : 0)
                                        .foregroundColor(.blue)
                                }
                                .contentShape(Rectangle())
                            })
                                .buttonStyle(PlainButtonStyle())
                            
                        }
                    } label: {
                        HStack {
                            Text("Select a camera")
                            Spacer()
                            Text(viewModel.selectedCameraName?.rawValue ?? "all")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("reset") {
                        viewModel.resetFiltering()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                        feedFiltering = viewModel.feedFiltering()
                    } label : {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Feed Filtering")
        }
    }
}

struct MarsRoversFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        MarsRoversFilteringView(roverInfo: RoverInfoFactory.makeCuriosityRoverInfo(), feedFiltering: .constant(nil))
    }
}


class MarsRoversFilteringViewModel: ObservableObject {
    let roverInfo: RoverInfo
    @Published var selectedDate: Date
    @Published private(set) var selectedCameraName: RoverCamera.CameraName? = nil
    
    init(roverInfo: RoverInfo) {
        self.roverInfo = roverInfo
        self._selectedDate = .init(wrappedValue: roverInfo.lastImageryDate ?? .now)
    }
    
    var filteringDateRange: ClosedRange<Date> {
        return .init(uncheckedBounds: (lower: roverInfo.landingDate, upper: roverInfo.lastImageryDate ?? .now))
    }
    
    var roverCameras: [RoverCamera.CameraName] {
        return roverInfo.availableCameras.sorted(by: { lhs, rhs in
            lhs.rawValue < rhs.rawValue
        })
    }
    
    func select(cameraName: RoverCamera.CameraName) {
        if selectedCameraName == cameraName {
            selectedCameraName = nil
        } else {
            selectedCameraName = cameraName
        }
    }
    
    func isCameraNameSelected(cameraName: RoverCamera.CameraName) -> Bool {
        return selectedCameraName == cameraName
    }
    
    func resetFiltering() {
        selectedCameraName = nil
        selectedDate = filteringDateRange.upperBound
    }
    
    func feedFiltering() -> RoverImageryFeedFiltering {
        return .init(imageriesDate: selectedDate, selectedCameraName: selectedCameraName)
    }
    
}


struct RoverImageryFeedFiltering {
    let imageriesDate: Date
    let selectedCameraName: RoverCamera.CameraName?
}
