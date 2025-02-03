//
//  LocationManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import CoreLocation
import FirebaseFirestore
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var userLocation: CLLocationCoordinate2D? // Stores user coordinates
    @Published var address: String? = "Detecting location..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: GeoPoint? // ✅ Stores the converted location as GeoPoint
    @Published var region: MKCoordinateRegion = MKCoordinateRegion( // Default region
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request permission when initializing
    }
    
    
    /// **📌 Get Sorted Kitchens by Distance**
    func getSortedKitchens(_ kitchens: [Kitchen]) -> [Kitchen] {
        guard let userLocation = userLocation else { return kitchens }

        return kitchens.sorted { kitchen1, kitchen2 in
            let location1 = CLLocation(latitude: kitchen1.location.latitude, longitude: kitchen1.location.longitude)
            let location2 = CLLocation(latitude: kitchen2.location.latitude, longitude: kitchen2.location.longitude)
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

            let distance1 = userCLLocation.distance(from: location1)
            let distance2 = userCLLocation.distance(from: location2)

            return distance1 < distance2 // ✅ Sort by nearest first
        }
    }


    func convertAddressToGeoPoint(_ address: String, completion: @escaping (GeoPoint?) -> Void) {
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, let location = placemark.location else {
                print("❌ Geocoding failed for address: \(address), Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let geoPoint = GeoPoint(latitude: latitude, longitude: longitude)

            DispatchQueue.main.async {
                self.location = geoPoint
                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }

            print("✅ Address converted to GeoPoint: (\(latitude), \(longitude))")
            completion(geoPoint) // ✅ Return converted GeoPoint
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

    // 🔹 Fetch the user's location (only call if authorized)
    func getCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            print("⚠️ Location services are disabled.")
        }
    }

    // 🔹 Called when location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        reverseGeocode(location: location)

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }

    // 🔹 Convert coordinates to a human-readable address
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, error == nil else {
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
