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
    fileprivate  var imageURL: URL!
    var isStatusBarHidden = false
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    fileprivate convenience init(imageURL: URL) {
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
        imageView.kf.setImage(with: imageURL, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 5, retryInterval: .seconds(2)))])
    }
    
    // MARK: Image Options AlertController
    func makeImageOptionsAlertController(forImage image: UIImage) -> UIAlertController {
        let alertTitle = NSLocalizedString("Imagery options", comment: "")
        let saveActionTitle = NSLocalizedString("Save", comment: "")
        let shareActionTitle = NSLocalizedString("Share", comment: "")
        let cancelActionTitle = NSLocalizedString("cancel", comment: "")
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        [
            UIAlertAction(title: saveActionTitle, style: .default) { [weak self] action in
                self?.saveImageActionHandler(action: action, image: image)
            },
            UIAlertAction(title: shareActionTitle, style: .default) { [weak self]  action in
                self?.shareImageHandler(image: image)
            },
            UIAlertAction(title: cancelActionTitle, style: .cancel),
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
            self.isStatusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        UIView.animate(withDuration: 0.25) {
            self.imageOptionsButton.transform = CGAffineTransform(translationX: 0, y: -32)
            self.dismissButton.transform = CGAffineTransform(translationX: 0, y: -32)
            self.imageOptionsButton.alpha = 0
            self.dismissButton.alpha = 0
            self.isStatusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: handlers
    func saveImageActionHandler(action: UIAlertAction, image: UIImage) {
        if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } else {
            present(UIAlertController.imageAuthNotGrantedAlertController(), animated: true, completion: nil)
        }
    }
    
    func shareImageHandler(image: UIImage) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
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
