//
//  ImagePresentationViewController.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 29/01/2022.
//

import UIKit
import SwiftUI
import Photos
import Kingfisher

struct ImagePresentationView: UIViewControllerRepresentable {
    let imageURL: URL
    typealias UIViewControllerType = ImagePresentationViewController
    func makeUIViewController(context: Context) -> ImagePresentationViewController {
        return ImagePresentationViewController(imageURL: imageURL)
    }
    
    func updateUIViewController(_ uiViewController: ImagePresentationViewController, context: Context) {
        
    }
    
}

class ImagePresentationViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var imageOptionsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: URL!
    convenience init(imageURL: URL) {
        self.init()
        self.imageURL = imageURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupDoubleTapZoomingGesture()
        setupImageView()
    }
    
    fileprivate func setupScrollView() {
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
    }
    
    fileprivate func setupDoubleTapZoomingGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
    }
    
    fileprivate func setupImageView() {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(3)))])
    }
    
    // MARK: Image Options AlertController
    func makeImageOptionsAlertController(forImage image: UIImage) -> UIAlertController {
        let alertController = UIAlertController(title: "Imagery options", message: nil, preferredStyle: .actionSheet)
        [
            UIAlertAction(title: "Save", style: .default) { [weak self] action in
                self?.saveImageActionHandler(action, image)
            },
            UIAlertAction(title: "Share", style: .default) { [weak self]  action in
                let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self?.present(activityController, animated: true, completion: nil)
            },
            UIAlertAction(title: "cancel", style: .cancel),
        ].forEach({ alertController.addAction($0) })
        return alertController
    }
    
    // MARK: ScrollView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard scrollView.zoomScale <= 1 else { return }
        UIView.animate(withDuration: 0.25) {
            self.imageOptionsButton.transform = .identity
            self.dismissButton.transform = .identity
            self.imageOptionsButton.alpha = 1
            self.dismissButton.alpha = 1
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        UIView.animate(withDuration: 0.25) {
            self.imageOptionsButton.transform = CGAffineTransform(translationX: 0, y: -32)
            self.dismissButton.transform = CGAffineTransform(translationX: 0, y: -32)
            self.imageOptionsButton.alpha = 0
            self.dismissButton.alpha = 0
        }
    }
    
    // MARK: handlers
    lazy var saveImageActionHandler: (UIAlertAction, UIImage) -> () = { [weak self] action, image  in
        if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } else {
            self?.present(UIAlertController.imageAuthNotGrantedAlertController(), animated: true, completion: nil)
        }
    }
    
    @objc
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        let selectedPoint = gesture.location(in: imageView)
        if scrollView.zoomScale >= scrollView.maximumZoomScale {
            scrollView.setZoomScale(1, animated: true)
        } else {
            scrollView.zoom(to: .init(origin: selectedPoint, size: .zero), animated: true)
        }
    }

    @IBAction func handleDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleImageOptions(_ sender: Any) {
        guard let image = imageView.image else { return }
        let alertController = makeImageOptionsAlertController(forImage: image)
        present(alertController, animated: true)
    }
    
}