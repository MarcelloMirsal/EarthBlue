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


class EventDetailsViewController: UIViewController, MKMapViewDelegate {
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    let mapView = MKMapView()
    var viewModel: EventDetailsViewModel!
    let pointIdentifier = "pointIdentifier"
    
    convenience init(event: Event) {
        self.init()
        self.viewModel = .init(event: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMapView()
    }
    
    // MARK: setup methods
    private func setupViews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: pointIdentifier)
        addingAnnotationToMapView()
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    private func addingAnnotationToMapView() {
        let locationsInfo = viewModel.locationsInfo()
        for locationInfo in locationsInfo {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationInfo.location
            annotation.title = locationInfo.date
            mapView.addAnnotation(annotation)
        }
    }
    
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
}
