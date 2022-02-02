//
//  MarsRoversFilteringViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 01/02/2022.
//

import Foundation

class MarsRoversFilteringViewModel: ObservableObject {
    let roverInfo: RoverInfo
    @Published var selectedDate: Date
    @Published private(set) var selectedCameraName: RoverCamera.CameraName? = nil
    
    init(roverInfo: RoverInfo, lastFeedFiltering: RoverImageryFeedFiltering?) {
        self.roverInfo = roverInfo
        if let lastFeedFiltering = lastFeedFiltering {
            self._selectedDate = .init(wrappedValue: lastFeedFiltering.imageriesDate)
            self._selectedCameraName = .init(wrappedValue: lastFeedFiltering.selectedCameraName)
        } else {
            self._selectedDate = .init(wrappedValue: roverInfo.lastImageriesDate ?? .now)
        }
    }
    
    var filteringDateRange: ClosedRange<Date> {
        return .init(uncheckedBounds: (lower: roverInfo.firstImageriesDate, upper: roverInfo.lastImageriesDate ?? .now))
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
