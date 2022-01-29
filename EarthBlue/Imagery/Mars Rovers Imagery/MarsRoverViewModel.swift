//
//  MarsRoverViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import Foundation
import NetworkingServices

class MarsRoverViewModel: ObservableObject {
    
    @Published var imageryFeed: RoverImageryFeed
    @Published var error: Error? = nil
    @Published var requestStatus: RequestStatus = .success
    let imageryService: MarsRoversService
    
    init() {
        self.imageryFeed = RoverImageryFeed(photos: [])
        self.imageryService = MarsRoversService()
        Task {
            await requestLatestImageryFeed()
        }
    }
    
    var cameraTypes: [RoverCamera] {
        return imageryFeed.photos.map({ $0.camera })
    }
    
    var feedHeaderDateTitle: String {
        guard let stringDate = imageryFeed.photos.first?.earthDate else { return "" }
        let date = DateFormatter.date(from: stringDate)
        let styledDateFormatter = DateFormatter()
        styledDateFormatter.dateFormat = "MMM d, yyyy"
        return styledDateFormatter.string(from: date)
    }
    
    
    func imageries(fromCameraType cameraType: RoverCamera) -> [RoverImagery] {
        return imageryFeed.photos.filter({ $0.camera.id == cameraType.id })
    }
    
    @MainActor
    func refreshFeed() async {
        await requestLatestImageryFeed()
    }
    
    
    @MainActor
    func requestLatestImageryFeed() async {
        guard requestStatus != .loading else { return }
        requestStatus = .loading
        let result = await imageryService.requestCuriosityLastImagery(decodingType: RoverImageryFeed.self)
        handle(requestResult: result)
    }
    
    @MainActor
    private func handle(requestResult: Result<RoverImageryFeed, Error>) {
        switch requestResult {
        case .success(let feed):
            imageryFeed = feed
            requestStatus = .success
        case .failure(let requestError):
            error = requestError
            requestStatus = .failed
        }
    }
}
