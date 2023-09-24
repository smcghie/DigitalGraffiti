//
//  MapViewModel.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-29.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var galleries: [ArtGallery] = []
    @Published var showLocationsList: Bool = false
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    @Published var permissionDenied = false
    @Published var mapType: MKMapType = .standard
    @Published var locations: [ArtGallery]!
    @Published var mapLocation: ArtGallery?
    @Published var mapRegion: MKCoordinateRegion!

    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    func updateLocations(){
        self.mapLocation = galleries.first!
        self.mapRegion = MKCoordinateRegion()
        for location in self.galleries {
            let coord = doubleToCoordinate(location.coordinates)
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = coord
            mapView.addAnnotation(pointAnnotation)
        }
    }
    
    func doubleToCoordinate(_ input: [Double]) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: input[0], longitude: input[1])
    }
    
    func updateMapType(){
        if mapType == .standard{
            mapType = .hybrid
            mapView.mapType = mapType
        }else{
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    func focusLocation(){
        let currentLocation = CLLocationManager().location?.coordinate
        self.region = MKCoordinateRegion(center: currentLocation!, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }

    func nextButtonPressed(){
        guard let currentIndex = galleries.firstIndex(where: {$0 == mapLocation}) else{
            print("Could not find current index in locations array")
            return
        }
        
        let nextIndex = currentIndex + 1
        guard galleries.indices.contains(nextIndex) else{
            let firstLocation = galleries.first
            selectPlace(place: firstLocation!)
            return
        }
        
        let nextLocation = galleries[nextIndex]
        selectPlace(place: nextLocation)
    }

    func toggleLocationsList(){
        withAnimation(.easeInOut){
            showLocationsList.toggle()
        }
    }
    
    func selectPlace(place: ArtGallery){
        showLocationsList = false

        let coordinate = doubleToCoordinate(place.coordinates)
        print("COORDINATES: \(coordinate)")
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        mapView.addAnnotation(pointAnnotation)

        self.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapLocation = place
        mapView.setRegion(self.region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)

    }
    

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
}


