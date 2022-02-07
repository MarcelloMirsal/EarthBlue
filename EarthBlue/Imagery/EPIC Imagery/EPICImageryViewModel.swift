//
//  EPICImageryViewModel.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 27/12/2021.
//

import NetworkingServices
import Combine

class EPICImageryViewModel: ObservableObject {
    @Published private(set) var epicImagesFeed: EPICImagesFeed
    @Published private(set) var error: Error?
    @Published private(set) var requestStatus: RequestStatus = .initial
    @Published var imageryFiltering: EPICImageryFiltering? = nil
    var cancellable = Set<AnyCancellable>()

    let imageryService = EPICImageryService()

    var feedImages: [EPICImageIdentifiable] {
        return epicImagesFeed.epicImages.map({ EPICImageIdentifiable(epicImage: $0) })
    }

    init() {
        self.epicImagesFeed = .init(isEnhanced: false, epicImages: [])
        Task {
            await requestDefaultFeed()
        }
        $imageryFiltering
            .sink(receiveValue: feedFilteringHandler)
            .store(in: &cancellable)
    }
    
    lazy var feedFilteringHandler: (EPICImageryFiltering?) -> () = { [unowned self]  newImageryFiltering in
        epicImagesFeed = .init(epicImages: [])
        if let newImageryFiltering = newImageryFiltering {
            Task {
                await self.requestFilteredFeed()
            }
        } else {
            Task {
                await self.requestDefaultFeed()
            }
        }
    }
    
    // MARK: Accessors
    func set(error: Error?) {
        self.error = error
    }
    
    func index(of epicImage: EPICImage) -> Int {
        return epicImagesFeed.epicImages.firstIndex(where: {epicImage == $0}) ?? -1
    }
    
    var isFeedLoading: Bool {
        return requestStatus == .loading
    }
    
    var isFailedLoading: Bool {
        return requestStatus == .failed
    }
    
    var isFeedImagesEmpty: Bool {
        return requestStatus == .success && epicImagesFeed.epicImages.isEmpty
    }
    
    func feedSectionDate() -> String {
        let epicImage = epicImagesFeed.epicImages.first
        guard let imageDate = epicImage?.date else { return "" }
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
        let imageURLRequest = epicRouter.thumbImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: imageryFiltering?.isEnhanced ?? false)
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
    func requestFilteredFeed() async {
        guard requestStatus != .loading, let feedFiltering = imageryFiltering else { return }
        requestStatus = .loading
        let result = await imageryService.requestFilteredFeed(isImageryEnhanced: feedFiltering.isEnhanced, date: feedFiltering.date, decodingType: [EPICImage].self)
        handle(requestResult: result)
    }
    
    @MainActor
    func refreshFeed() async {
        if let _ = imageryFiltering {
            await requestFilteredFeed()
        } else {
            await requestDefaultFeed()
        }
    }
    
    private func handle(requestResult: Result<[EPICImage], Error>) {
        switch requestResult {
        case .success(let images):
            let isEnhanced = imageryFiltering?.isEnhanced ?? false
            epicImagesFeed = .init(isEnhanced: isEnhanced, epicImages: images)
            requestStatus = .success
        case .failure(let error):
            set(error: error)
            requestStatus = .failed
        }
    }
    
}

extension EPICImageryViewModel {
    
    struct EPICImagesFeed {
        var isEnhanced: Bool
        var epicImages: [EPICImage]
        
        init(isEnhanced: Bool = false, epicImages: [EPICImage]) {
            self.isEnhanced = isEnhanced
            self.epicImages = epicImages
        }
    }
    
    
    struct EPICImageIdentifiable: Identifiable, Equatable {
        var id: UUID = .init()
        let epicImage: EPICImage
    }
    
    
}
