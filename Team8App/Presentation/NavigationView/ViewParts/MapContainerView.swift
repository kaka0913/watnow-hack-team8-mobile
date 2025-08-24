//
//  MapContainerView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapContainerView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @Binding var annotations: [CustomAnnotation]
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.userLocation.title = "現在地"
        
        // Setup location manager
        context.coordinator.setupLocationManager(for: mapView)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region if it has changed
        if !mapView.region.isEqual(to: region) {
            mapView.setRegion(region, animated: true)
        }
        
        // Clear existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        
        // Add route polyline if coordinates exist
        if !routeCoordinates.isEmpty {
            let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            mapView.addOverlay(polyline)
        }
        
        // Add annotations
        mapView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapContainerView
        private var locationManager = CLLocationManager()
        private weak var mapView: MKMapView?
        
        init(_ parent: MapContainerView) {
            self.parent = parent
            super.init()
        }
        
        func setupLocationManager(for mapView: MKMapView) {
            self.mapView = mapView
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // Request location permission
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            default:
                break
            }
        }
        
        // MARK: - CLLocationManagerDelegate
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            
            // Update map region to center on user location if no route is set
            if parent.routeCoordinates.isEmpty {
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                DispatchQueue.main.async {
                    self.parent.region = region
                }
            }
            
            // Notify parent about location update
            parent.onLocationUpdate?(location.coordinate)
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                mapView?.showsUserLocation = true
            case .denied, .restricted:
                mapView?.showsUserLocation = false
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location manager failed with error: \(error.localizedDescription)")
        }
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // Update user location display
            if let location = userLocation.location {
                parent.onLocationUpdate?(location.coordinate)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザーの現在位置のカスタマイズ
            if annotation is MKUserLocation {
                let identifier = "UserLocation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    
                    // カスタム現在位置アイコン
                    let userLocationView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    userLocationView.backgroundColor = .systemBlue
                    userLocationView.layer.cornerRadius = 10
                    userLocationView.layer.borderWidth = 3
                    userLocationView.layer.borderColor = UIColor.white.cgColor
                    userLocationView.layer.shadowColor = UIColor.black.cgColor
                    userLocationView.layer.shadowOffset = CGSize(width: 0, height: 2)
                    userLocationView.layer.shadowRadius = 3
                    userLocationView.layer.shadowOpacity = 0.3
                    
                    // UIViewをUIImageに変換
                    UIGraphicsBeginImageContextWithOptions(userLocationView.bounds.size, false, 0.0)
                    if let context = UIGraphicsGetCurrentContext() {
                        userLocationView.layer.render(in: context)
                        let image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        annotationView?.image = image
                    }
                }
                
                annotationView?.annotation = annotation
                return annotationView
            }
            
            if let customAnnotation = annotation as? CustomAnnotation {
                let identifier = "CustomAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                }
                
                if let markerView = annotationView as? MKMarkerAnnotationView {
                    switch customAnnotation.type {
                    case .start:
                        markerView.markerTintColor = .green
                        markerView.glyphText = "S"
                    case .end:
                        markerView.markerTintColor = .red
                        markerView.glyphText = "E"
                    case .waypoint:
                        markerView.markerTintColor = .orange
                        markerView.glyphText = "W"
                    }
                }
                
                annotationView?.annotation = annotation
                return annotationView
            }
            
            return nil
        }
    }
}

class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let type: AnnotationType
    
    enum AnnotationType {
        case start
        case end
        case waypoint
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, type: AnnotationType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        super.init()
    }
}

extension MKCoordinateRegion {
    func isEqual(to other: MKCoordinateRegion) -> Bool {
        return abs(center.latitude - other.center.latitude) < 0.0001 &&
               abs(center.longitude - other.center.longitude) < 0.0001 &&
               abs(span.latitudeDelta - other.span.latitudeDelta) < 0.0001 &&
               abs(span.longitudeDelta - other.span.longitudeDelta) < 0.0001
    }
}