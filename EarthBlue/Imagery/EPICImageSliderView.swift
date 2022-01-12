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

struct EPICImageSliderView: UIViewControllerRepresentable {
    let epicImagesFeed: EPICImagesFeed
    func makeUIViewController(context: Context) -> EPICImageSliderViewController {
        EPICImageSliderViewController.instantiate(epicImagesFeed: epicImagesFeed)
    }
    
    func updateUIViewController(_ uiViewController: EPICImageSliderViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = EPICImageSliderViewController
}

struct EPICImageSliderView_Preview: PreviewProvider {
    static var previews: some View {
        EPICImageSliderView(epicImagesFeed: .init(epicImages: []))
    }
}


class EPICImageSliderViewController: UIViewController, UICollectionViewDelegate {
    
    static func instantiate(epicImagesFeed: EPICImagesFeed) -> Self {
        let epicImageSliderViewController = UIStoryboard(name: "EPICImageSliderViewController", bundle: nil).instantiateInitialViewController() as! Self
        epicImageSliderViewController.epicImagesFeed = epicImagesFeed
        return epicImageSliderViewController
    }
    
    @IBOutlet weak var pageControlView: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    var epicImagesFeed: EPICImagesFeed!
    var dataSource: UICollectionViewDiffableDataSource<Section, EPICImage>!
    lazy var cellRegistration: UICollectionView.CellRegistration<ImageViewCell, EPICImage> = .init(handler: imageCellRegistrationHandler)
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        pageControlView.numberOfPages = epicImagesFeed.epicImages.count
        pageControlView.currentPage = 0
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
            return cell
        })
        collectionView.dataSource = dataSource
        
        var updatedSnapshot = dataSource.snapshot()
        updatedSnapshot.appendSections([.main])
        updatedSnapshot.appendItems(epicImagesFeed.epicImages, toSection: .main)
        dataSource.apply(updatedSnapshot)
    }
    
    // MARK: Cell registration handler
    lazy var imageCellRegistrationHandler: (ImageViewCell, IndexPath, EPICImage) -> () = { [epicImagesFeed = epicImagesFeed!] cell, indexPath, epicImage in
        let router = EPICImageryRouter()
        let urlRequest = router.thumbImageRequest(imageName: epicImage.image, stringDate: epicImage.date, isEnhanced: epicImagesFeed.isEnhanced)
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(with: urlRequest.url!)
    }
    
    // MARK: CollectionView Delegate methods
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.prepareForReuse()
        guard let cell = collectionView.visibleCells.first else { return }
        guard let visibleCellIndexPath = collectionView.indexPath(for: cell) else { return }
        pageControlView.currentPage = visibleCellIndexPath.row
    }
    
    @IBAction func handleDismiss() {
        dismiss(animated: true)
    }
    
    enum Section {
        case main
    }
}

class ImageViewCell: UICollectionViewCell, UIScrollViewDelegate {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EPICImageThumb")
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
