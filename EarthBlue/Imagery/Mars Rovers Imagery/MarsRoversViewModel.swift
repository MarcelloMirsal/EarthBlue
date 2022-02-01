//
//  MarsRoversViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import Combine
import NetworkingServices

class MarsRoversViewModel: ObservableObject {
    
    @Published private(set) var imageryFeed: RoverImageryFeed
    @Published private(set) var error: Error? = nil
    @Published private(set) var requestStatus: RequestStatus = .success
    @Published var feedFiltering: RoverImageryFeedFiltering?
    
    private var cancellable = Set<AnyCancellable>()
    let marsRoversImageryService: MarsRoversService
    
    init() {
        self.imageryFeed = RoverImageryFeed(photos: [])
        self.marsRoversImageryService = MarsRoversService()
        self.$feedFiltering
            .dropFirst()
            .sink(receiveValue: self.feedFilteringUpdateHandler)
            .store(in: &cancellable)
        Task {
            await requestLatestImageryFeed()
        }
    }
    
    var cameraTypes: [RoverCamera] {
        let camerasSet = Set(imageryFeed.photos.map({$0.camera}))
        return Array(camerasSet).sorted(by: { $0.name.fullName < $1.name.fullName })
    }
    
    func set(error: Error?) {
        self.error = nil
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
        switch feedFiltering {
        case .some:
            await requestFilteredImageries()
        case .none:
            await requestLatestImageryFeed()
        }
    }
    
    @MainActor
    func requestLatestImageryFeed() async {
        guard requestStatus != .loading else { return }
        requestStatus = .loading
        let result = await marsRoversImageryService.requestCuriosityLastImagery(decodingType: RoverImageryFeed.self)
        handle(requestResult: result)
    }
    
    @MainActor
    func requestFilteredImageries() async {
        guard let feedFiltering = feedFiltering else { return }
        requestStatus = .loading
        let requestResult = await marsRoversImageryService.requestFilteredImageriesFeed(date: feedFiltering.imageriesDate, cameraType: feedFiltering.selectedCameraName?.rawValue, decodingType: RoverImageryFeed.self)
        handle(requestResult: requestResult)
    }
    
    @MainActor
    private func handle(requestResult: Result<RoverImageryFeed, Error>) {
        switch requestResult {
        case .success(let feed):
            imageryFeed = feed
            requestStatus = .success
        case .failure(let requestError):
            requestStatus = .failed
            error = requestError
        }
    }
    
    lazy var feedFilteringUpdateHandler: (RoverImageryFeedFiltering?) -> () = { newFeedFiltering in
        self.imageryFeed = .init(photos: [])
        Task { [weak self] in
            await self?.requestFilteredImageries()
        }
    }
}
