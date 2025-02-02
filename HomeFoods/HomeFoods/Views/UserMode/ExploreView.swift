//
//  ExploreView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct ExploreView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.549099, longitude: -121.943069), // Default location
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @State private var selectedKitchen: Kitchen? // Track the selected kitchen
    @State private var showDetail = false // Navigation flag
    @State private var lastKnownLocation: CLLocationCoordinate2DWrapper? // ✅ Custom Equatable Wrapper
    @State private var kitchens: [Kitchen] = [] // Store kitchens fetched from Firestore

    var body: some View {
        NavigationStack {
            ZStack {
                // 📌 Interactive Map
                Map(position: $position) {
                    ForEach(appViewModel.kitchens) { kitchen in
                        let coordinate = CLLocationCoordinate2D(
                            latitude: kitchen.location.latitude,
                            longitude: kitchen.location.longitude
                        )

                        Annotation(kitchen.name, coordinate: coordinate) {
                            Button(action: {
                                selectedKitchen = kitchen
                                showDetail = true
                            }) {
                                VStack {
                                    AsyncImage(url: URL(string: kitchen.imageUrl ?? "")) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 3)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .background(Color.gray.opacity(0.3))
                                    }

                                    Text(kitchen.name)
                                        .font(.caption)
                                        .bold()
                                        .padding(5)
                                        .background(Color.white.opacity(0.8))
                                        .cornerRadius(5)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Explore Nearby")
                .navigationBarTitleDisplayMode(.inline)

                // 📌 "Find My Location" Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            if let userLocation = locationManager.userLocation {
                                updateUserLocation(userLocation)
                            }
                        }) {
                            Image(systemName: "location.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                appViewModel.fetchKitchens() // ✅ Fetch kitchens from Firestore
                locationManager.requestLocationPermission()
            }
            .onChange(of: locationManager.userLocation.map { CLLocationCoordinate2DWrapper(coordinate: $0) }) { newLocation in
                if let newLocation = newLocation, newLocation != lastKnownLocation {
                    updateUserLocation(newLocation.coordinate)
                    lastKnownLocation = newLocation // ✅ Update last known location
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let kitchen = selectedKitchen {
                    KitchenDetailView(kitchen: kitchen)
                }
            }
        }
    }

    /// 📌 Updates user location on the map
    private func updateUserLocation(_ location: CLLocationCoordinate2D) {
        position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    }
}

/// 📌 Custom Equatable Wrapper for CLLocationCoordinate2D
struct CLLocationCoordinate2DWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CLLocationCoordinate2DWrapper, rhs: CLLocationCoordinate2DWrapper) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
