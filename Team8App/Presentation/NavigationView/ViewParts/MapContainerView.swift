//
//  MapContainerView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit

struct MapContainerView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @Binding var annotations: [CustomAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
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
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapContainerView
        
        init(_ parent: MapContainerView) {
            self.parent = parent
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
            if annotation is MKUserLocation {
                return nil
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