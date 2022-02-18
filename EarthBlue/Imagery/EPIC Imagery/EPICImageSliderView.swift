//
//  EPICImageSliderView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 10/01/2022.
//

import UIKit
import SwiftUI
import Kingfisher
import NetworkingServices
import Photos


typealias EPICImagesFeed = EPICImageryViewModel.EPICImagesFeed

struct EPICImageSliderView: UIViewControllerRepresentable {
    typealias UIViewControllerType = EPICImageSliderViewController
    let epicImage: EPICImage
    let isEnhanced: Bool
    func makeUIViewController(context: Context) -> EPICImageSliderViewController {
        return EPICImageSliderViewController(epicImage: epicImage, isEnhanced: isEnhanced)
    }
    
    func updateUIViewController(_ uiViewController: EPICImageSliderViewController, context: Context) {
        
    }
}

struct EPICImageSliderView_Preview: PreviewProvider {
    static var previews: some View {
        EPICImageSliderView(epicImage: .init(identifier: "20220118003633", image: "epic_1b_20220118003633", caption: "CAPTION", date: "2022-01-18 00:31:45"), isEnhanced: false)
    }
}

final class EPICImageSliderViewController: ImagePresentationViewController {
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(progressView, at: 0)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        progressView.isHidden = true
        return progressView
    }()
    
    let epicImage: EPICImage
    let isEnhanced: Bool
    let epicImageryRouter = EPICImageryRouter()
    var originalImageryDownloadTask: DownloadTask?
    var router: EPICImageryRouter = EPICImageryRouter()
    
    fileprivate init(epicImage: EPICImage, isEnhanced: Bool) {
        self.epicImage = epicImage
        self.isEnhanced = isEnhanced
        super.init(nibName: "ImagePresentationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        originalImageryDownloadTask?.cancel()
    }
    
    
    // MARK: View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupImageViewForEPICImage()
    }
    
    func setupImageViewForEPICImage() {
        let originalURLRequest = router.originalImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: isEnhanced)
        let thumbImageURLRequest = router.thumbImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: isEnhanced)
        imageView.kf.indicatorType = .activity
        
        if ImageCache.default.isCached(forKey: originalURLRequest.url!.absoluteString) {
            imageView.kf.setImage(with: originalURLRequest.url!)
            
        } else {
            imageView.kf.setImage(with: thumbImageURLRequest.url!, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2)))])
        }
    }
    
    // MARK: Image Options AlertController
    override func makeImageOptionsAlertController(forImage image: UIImage) -> UIAlertController {
        let alertController = UIAlertController(title: "Imagery options", message: nil, preferredStyle: .actionSheet)
        [
            UIAlertAction(title: "Save", style: .default) { [weak self] action in
                self?.saveImageActionHandler(action: action, image: image)
            },
            UIAlertAction(title: "Load high quality imagery", style: .default) { [weak self, epicImage = self.epicImage] action in
                self?.loadHighQualityImage(epicImage: epicImage)
            },
            UIAlertAction(title: "Share", style: .default) { [weak self]  action in
                self?.shareImageHandler(image: image)
            },
            UIAlertAction(title: "cancel", style: .cancel),
        ].forEach({ alertController.addAction($0) })
        return alertController
    }
    
    func loadHighQualityImage(epicImage: EPICImage) {
        guard originalImageryDownloadTask == nil else { return }
        progressView.isHidden = false
        let urlRequest = EPICImageryRouter().originalImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: isEnhanced)
        
        Kingfisher.ImageDownloader.default.downloadTimeout = 2 * 60
        
        originalImageryDownloadTask = KingfisherManager.shared.retrieveImage(with: urlRequest.url!, options: [.waitForCache]) { [weak self] receivedSize, totalSize in
            let progress = Double(receivedSize) / Double(totalSize)
            self?.progressView.setProgress(Float(progress), animated: true)
        } completionHandler: { [weak self] result in
            self?.setupImageViewForEPICImage()
            self?.progressView.isHidden = true
        }
    }
}
