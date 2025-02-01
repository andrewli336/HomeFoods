//
//  LocationManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D? // Stores user coordinates
    @Published var address: String? = "Detecting location..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Fetch the user's location (Only call if authorized)
    func getCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            print("⚠️ Location services are disabled.")
        }
    }
    
    // 🔹 Called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.getCurrentLocation()
            }
        }
    }
    
    // 🔹 Called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.global(qos: .background).async {
            self.reverseGeocode(location: location)
        }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    // 🔹 Convert coordinates to human-readable address
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
                print("❌ Reverse geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let addressString = [
                placemark.subThoroughfare, // House number
                placemark.thoroughfare, // Street name
                placemark.locality, // City
                placemark.administrativeArea, // State
                placemark.postalCode, // ZIP
                placemark.country // Country
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
            
            DispatchQueue.main.async {
                self.address = addressString
            }
        }
    }

    // 🔹 Handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to find user's location: \(error.localizedDescription)")
    }
}
