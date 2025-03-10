//
//  MapViewContainer.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//
import SwiftUI
import MapplsMap

struct MapViewContainer: UIViewRepresentable {
    @Binding var mapView: MapplsMapView?
    var onMapLoaded: (() -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        // Initialize MapplsMapView
        let mapView = MapplsMapView(frame: .zero)
        mapView.delegate = context.coordinator
        
        // Enable user location
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Set initial center and zoom level (New Delhi as default)
        mapView.setCenter(CLLocationCoordinate2DMake(28.551438, 77.265119), zoomLevel: 12, animated: false)
        
        print("DEBUG: MapplsMapView initialized")
        self.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update map if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MapplsMapViewDelegate {
        var parent: MapViewContainer
        
        init(_ parent: MapViewContainer) {
            self.parent = parent
            super.init()
        }
        
        // Map is loaded and ready to use
        func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
            print("DEBUG: Map finished loading")
            parent.onMapLoaded?()
        }
        
        // User location updated
        func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
            print("DEBUG: User location updated")
        }
    }
}
