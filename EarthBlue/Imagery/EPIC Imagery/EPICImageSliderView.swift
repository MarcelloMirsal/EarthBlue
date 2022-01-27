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
    
    let epicImagesFeed: EPICImagesFeed
    init(epicImagesFeed: EPICImagesFeed) {
        self.epicImagesFeed = epicImagesFeed
    }
    func makeUIViewController(context: Context) -> EPICImageSliderViewController {
        return EPICImageSliderViewController.instantiate(epicImagesFeed: epicImagesFeed)
    }
    
    func updateUIViewController(_ uiViewController: EPICImageSliderViewController, context: Context) {
        
    }
}

struct EPICImageSliderView_Preview: PreviewProvider {
    static var previews: some View {
        EPICImageSliderView(epicImagesFeed: .init(epicImages: [
            .init(identifier: "20220118003633", image: "epic_1b_20220118003633", caption: "CAPTION", date: "2022-01-18 00:31:45")
        ]))
    }
}

class EPICImageSliderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    static func instantiate(epicImagesFeed: EPICImagesFeed) -> Self {
        let epicImageSliderViewController = UIStoryboard(name: "EPICImageSliderViewController", bundle: nil).instantiateInitialViewController() as! Self
        epicImageSliderViewController.epicImagesFeed = epicImagesFeed
        return epicImageSliderViewController
    }
    deinit {
        originalImageryDownloadTask?.cancel()
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var epicImagesFeed: EPICImagesFeed!
    var dataSource: UICollectionViewDiffableDataSource<Section, EPICImage>!
    lazy var cellRegistration: UICollectionView.CellRegistration<SliderImageViewCell, EPICImage> = .init(handler: imageCellRegistrationHandler)
    let epicImageryRouter = EPICImageryRouter()
    var originalImageryDownloadTask: DownloadTask?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
    }
    
    // MARK: Setup methods
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(getCollectionViewLayout(), animated: true)
    }
    
    func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    fileprivate func setupDataSource() {
        dataSource = .init(collectionView: collectionView, cellProvider: { [cellRegistration = cellRegistration] collectionView, indexPath, epicImage in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: epicImage)
            cell.prepareForReuse()
            return cell
        })
        collectionView.dataSource = dataSource
        var updatedSnapshot = dataSource.snapshot()
        updatedSnapshot.appendSections([.main])
        updatedSnapshot.appendItems(epicImagesFeed.epicImages, toSection: .main)
        dataSource.apply(updatedSnapshot)
    }
    
    func imageOptionsAlertController(forImage image: UIImage, epicImage: EPICImage) -> UIAlertController {
        let alertController = UIAlertController(title: "Imagery options", message: nil, preferredStyle: .actionSheet)
        [
            UIAlertAction(title: "Save", style: .default) { [weak self] action in
                self?.saveImageActionHandler(action, image)
            },
            UIAlertAction(title: "Load high quality imagery", style: .default) { [weak self] action in
                self?.loadHighQualityImage(epicImage: epicImage)
            },
            UIAlertAction(title: "Share", style: .default) { [weak self]  action in
                self?.shareImageActionHandler(action, image)
            },
            UIAlertAction(title: "cancel", style: .cancel),
        ].forEach({ alertController.addAction($0) })
        return alertController
    }
    
    
    func loadHighQualityImage(epicImage: EPICImage) {
        guard originalImageryDownloadTask == nil else { return }
        progressView.isHidden = false
        let urlRequest = EPICImageryRouter().originalImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: epicImagesFeed.isEnhanced)
        Kingfisher.ImageDownloader.default.downloadTimeout = 2 * 60
        originalImageryDownloadTask = KingfisherManager.shared.retrieveImage(with: urlRequest.url!, options: [.waitForCache]) { [weak self] receivedSize, totalSize in
            let progress = Double(receivedSize) / Double(totalSize)
            self?.progressView.setProgress(Float(progress), animated: true)
        } completionHandler: { [weak self] result in
            guard var currentSnapshot = self?.dataSource.snapshot() else {return}
            currentSnapshot.reloadSections([.main])
            self?.dataSource.apply(currentSnapshot, animatingDifferences: false)
            self?.progressView.isHidden = true
        }
    }
    
    
    // MARK: Cell registration handler
    lazy var imageCellRegistrationHandler: (SliderImageViewCell, IndexPath, EPICImage) -> () = { [epicImagesFeed = epicImagesFeed!, weak self] cell, indexPath, epicImage in
        let router = EPICImageryRouter()
        
        // load high image if cached
        let originalURLRequest = router.originalImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: epicImagesFeed.isEnhanced)
        let thumbImageURLRequest = router.thumbImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: epicImagesFeed.isEnhanced)
    
        cell.imageView.kf.indicatorType = .activity
        
        if ImageCache.default.isCached(forKey: originalURLRequest.url!.absoluteString) {
            cell.imageView.kf.setImage(with: originalURLRequest.url!)
            
        } else {
            cell.imageView.kf.setImage(with: thumbImageURLRequest.url!, options: [.retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2)))])
        }
    }
    
    // MARK: handlers
    @IBAction func handleDismiss() {
        dismiss(animated: true)
    }
    
    @IBAction func handleImageOptions(_ sender: Any) {
        guard let currentCell = collectionView.visibleCells.first as? SliderImageViewCell else {return}
        guard let indexPath = collectionView.indexPath(for: currentCell) else { return }
        guard let image = currentCell.imageView.image else { return }
        let epicImage = epicImagesFeed.epicImages[indexPath.row]
        present(imageOptionsAlertController(forImage: image, epicImage: epicImage), animated: true)
    }
    
    // MARK: Imagery Options Handlers
    lazy var saveImageActionHandler: (UIAlertAction, UIImage) -> () = { [weak self] action, image  in
        if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } else {
            self?.presentImageAuthNotGrantedAlert()
        }
    }
    
    lazy var shareImageActionHandler: (UIAlertAction, UIImage) -> () = { [weak self] action, image  in
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self?.present(activityController, animated: true, completion: nil)
    }
    
    // MARK: presentations
    func presentImageAuthNotGrantedAlert() {
        let alertController = UIAlertController(title: "can't save image, please grant permission from Settings.", message: nil, preferredStyle: .alert)
        let permissionsSettingsAction = UIAlertAction(title: "Settings", style: .default) { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(permissionsSettingsAction)
        alertController.preferredAction = permissionsSettingsAction
        present(alertController, animated: true)
    }
    
    enum Section {
        case main
    }
}

class SliderImageViewCell: UICollectionViewCell, UIScrollViewDelegate {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        return scrollView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.zoomScale = 1
    }
    
    enum Section {
        case main
    }
    
}
