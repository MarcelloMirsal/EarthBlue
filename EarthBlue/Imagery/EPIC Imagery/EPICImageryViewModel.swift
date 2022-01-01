//
//  EPICImageryViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import NetworkingServices
import Combine
import Foundation

class EPICImageryViewModel: ObservableObject {
    @Published var epicImages: [EPICImageIdentifiable]
    @Published private(set) var error: Error?
    @Published private var requestStatus: RequestStatus = .success
    
    
    let imageryService = EPICImageryService()
    init() {
        self.epicImages = []
        Task {
            await requestDefaultFeed()
        }
    }
    
    // MARK: Accessors
    func set(error: Error?) {
        self.error = error
    }

    var isFeedLoading: Bool {
        return requestStatus == .loading
    }
    
    var isFailedLoading: Bool {
        return requestStatus == .failed
    }
    
    func feedSectionDate() -> String {
        guard let imageDate = epicImages.first?.epicImage.date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = .current
        dateFormatter.calendar = .current
        let date = dateFormatter.date(from: imageDate)!
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func thumbImageURLRequest(for epicImage: EPICImage) -> URLRequest {
        let epicRouter = EPICImageryRouter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = .current
        dateFormatter.calendar = .current
        let imageDate = dateFormatter.date(from: epicImage.date)!
        let imageURLRequest = epicRouter.thumbImageRequest(imageName: epicImage.image, date: imageDate, isEnhanced: false)
        return imageURLRequest
    }
    
    @MainActor
    func requestDefaultFeed() async {
        guard requestStatus != .loading else { return }
        requestStatus = .loading
        let result = await imageryService.requestDefaultFeed(decodableType: [EPICImage].self)
        handle(requestResult: result)
    }
    
    @MainActor
    func refreshFeed() async {
        await requestDefaultFeed()
    }
    
    private func handle(requestResult: Result<[EPICImage], Error>) {
        switch requestResult {
        case .success(let images):
            epicImages = images.map({EPICImageIdentifiable(epicImage: $0)})
            requestStatus = .success
        case .failure(let error):
            set(error: error)
            requestStatus = .failed
        }
    }
    
}


struct EPICImage: Codable {
    let identifier: String
    let image: String
    let caption: String
    let date: String
}


struct EPICImageIdentifiable: Identifiable {
    var id: UUID = .init()
    let epicImage: EPICImage
}
