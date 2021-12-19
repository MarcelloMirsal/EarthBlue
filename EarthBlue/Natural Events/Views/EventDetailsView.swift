//
//  EventDetailsView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 22/11/2021.
//

import UIKit
import MapKit
import SwiftUI

struct EventDetailsView: UIViewControllerRepresentable {
    typealias UIViewControllerType = EventDetailsViewController
    let event: Event
    
    func makeUIViewController(context: Context) -> EventDetailsViewController {
        return .init(event: event)
    }
    
    func updateUIViewController(_ uiViewController: EventDetailsViewController, context: Context) {
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(event: .polygonDetailedEventMock)
    }
}


class EventDetailsViewController: UIViewController {
    private let mapView = MKMapView()
    private var viewModel: EventDetailsViewModel!
    private let pointIdentifier = "pointIdentifier"
    
    private let mapTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.setTitle("Map type", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        return button
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .headline)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mapTypeButton, infoButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 24
        return stackView
    }()
    
    private lazy var optionsBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect:  effect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(optionsStackView)
        blurView.layer.cornerRadius = 8
        blurView.layer.masksToBounds = true
        return blurView
    }()
    
    convenience init(event: Event) {
        self.init()
        self.viewModel = .init(event: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMapView()
        setupMapTypeOptionsMenu()
        infoButton.addTarget(self, action: #selector(handleInfo), for: .touchUpInside)
    }
    @objc
    func handleInfo() {
        let hostingView = UIHostingController(rootView: EventDetailsInfoView(event: viewModel.event))
        if let sheet = hostingView.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(hostingView, animated: true)
    }
    
    
    // MARK: setup methods
    private func setupViews() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(optionsBlurView)
        NSLayoutConstraint.activate([
            optionsBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            optionsBlurView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: optionsBlurView.topAnchor, constant: 8),
            optionsStackView.leadingAnchor.constraint(equalTo: optionsBlurView.leadingAnchor, constant: 12),
            optionsStackView.trailingAnchor.constraint(equalTo: optionsBlurView.trailingAnchor, constant: -12),
            optionsStackView.bottomAnchor.constraint(equalTo: optionsBlurView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: pointIdentifier)
        guard let isCoordinatesInPoint = viewModel.isCoordinatesInPoint() else { return } // no coordinates found
        if isCoordinatesInPoint {
            addingAnnotationToMapView()
        } else {
            addingPolygonOverlay()
        }
    }
    
    private func setupMapTypeOptionsMenu() {
        let actions: [UIAction] = [
            .init(title: "Satellite", state: .off, handler: { [weak self] action in
                self?.mapView.mapType = .satellite
            }),
            .init(title: "Standard", state: .on, handler: { [weak self] action in
                self?.mapView.mapType = .standard
            })
        ]
        let menu = UIMenu(title: "Map type", options: [.singleSelection], children: actions)
        mapTypeButton.menu = menu
        mapTypeButton.showsMenuAsPrimaryAction = true
    }
    
    private func addingAnnotationToMapView() {
        let locationsInfo = viewModel.locationsInfo()
        for locationInfo in locationsInfo {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationInfo.location
            annotation.title = locationInfo.date
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    private func addingPolygonOverlay() {
        let locationsInfo = viewModel.locationsInfo()
        let coordinates = locationsInfo.map({$0.location})
        let polygonOverlay = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygonOverlay)
        mapView.centerCoordinate = coordinates.last ?? .init()
        mapView.centerCoordinate = polygonOverlay.coordinate
    }
}

// MARK: MKMapView delegate
extension EventDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointIdentifier)
        annotationView?.annotation = annotation
        annotationView?.displayPriority = .required
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let selectedAnnotation = view.annotation else { return }
        UIView.animate(withDuration: 0.5) {
            mapView.centerCoordinate = selectedAnnotation.coordinate
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolygonRenderer(overlay: overlay)
        render.fillColor = UIColor.green.withAlphaComponent(0.25)
        render.strokeColor = UIColor(Colors.caption)
        return render
    }
}


struct EventDetailsInfoView: View {
    let event: Event
    var body: some View {
        List {
            Section {
                InfoItemView(headline: "Category") {
                    ForEach(event.categories, id: \.id) { category in
                        Text(category.title)
                    }
                }
                InfoItemView(headline: "Status", content: {
                    Text(event.isActive ? "ACTIVE" : "CLOSED")
                })
                InfoItemView(headline: "Last update date", content: {
                    Text(event.lastUpdatedDate)
                })
                InfoItemView(headline: "Sources", content: {})
                ForEach(event.sources, id: \.id) { source in
                    if let url = URL(string: source.url) {
                        Link(source.id, destination: url)
                            .foregroundColor(.blue)
                            
                    }
                }
                .padding(.horizontal)
                .listRowBackground(Color.clear)
                
            } header: {
                Text(Event.activeEventMock.title)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .shadow(radius: 32)
            }
            .listRowInsets(EdgeInsets.init(top: 16, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
    }
}

fileprivate struct InfoItemView<Content: View>: View {
    let headline: String
    var content: Content
    init(headline: String, @ViewBuilder content: () -> Content ) {
        self.headline = headline
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline)
                .font(Font.title3.bold())
                .foregroundColor(.primary)
            content
        }
        .textSelection(.enabled)
        .padding(.horizontal)
    }
}
