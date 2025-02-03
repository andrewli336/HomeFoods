//
//  AddKitchenPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI
import CoreLocation
import MapKit
import FirebaseFirestore

struct MapAnnotationPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct AddKitchenPage: View {
    @Binding var kitchenName: String
    @Binding var kitchenDescription: String
    @Binding var kitchenCuisine: String
    var nextPage: (_ address: String, _ geoPoint: GeoPoint?) -> Void // ✅ Passes GeoPoint as well

    @StateObject private var locationManager = LocationManager()
    @State private var showAddressSelection = false
    @State private var selectedManualAddress: String? // ✅ Stores manually entered address
    @State private var geoPoint: GeoPoint? // ✅ Stores converted GeoPoint
    @State private var mapAnnotation: MapAnnotationPoint? // ✅ Stores converted location as an annotation

    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default: San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ScrollView { // ✅ Make the content scrollable
            VStack(spacing: 20) {
                Text("Set Up Your Kitchen")
                    .font(.largeTitle)
                    .bold()

                TextField("Kitchen Name", text: $kitchenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Kitchen Description", text: $kitchenDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Kitchen Cuisine", text: $kitchenCuisine)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // 📌 Address Display Logic
                VStack(alignment: .leading, spacing: 5) {
                    Text("Kitchen Address:")
                        .font(.headline)

                    let finalAddress = selectedManualAddress ?? locationManager.address ?? "No address"

                    Text(finalAddress)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                }
                .padding(.horizontal)

                // 📌 MapView showing location
                if let annotation = mapAnnotation {
                    Map(coordinateRegion: $region, annotationItems: [annotation]) { point in
                        MapMarker(coordinate: point.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                }

                Divider()

                // 📌 Manual Address Entry Button
                Button("Enter Address Manually") {
                    showAddressSelection = true
                }
                .foregroundColor(.blue)
                .padding()

                // 📌 Convert address to GeoPoint when Next is clicked
                Button("Next") {
                    let finalAddress = selectedManualAddress ?? locationManager.address ?? "No address"
                    
                    // ✅ Convert Address to GeoPoint before proceeding
                    locationManager.convertAddressToGeoPoint(finalAddress) { geoPoint in
                        self.geoPoint = geoPoint
                        if let geoPoint = geoPoint {
                            let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                            self.region = MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                            self.mapAnnotation = MapAnnotationPoint(coordinate: coordinate)
                        }
                        nextPage(finalAddress, geoPoint) // ✅ Pass both address and GeoPoint
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
        .sheet(isPresented: $showAddressSelection) {
            AddressSelectionView(selectedAddress: $selectedManualAddress, showAddressSelection: $showAddressSelection)
        }
    }
}
