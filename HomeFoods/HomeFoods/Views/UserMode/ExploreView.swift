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
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.549099, longitude: -121.943069),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    @State private var selectedKitchen: Kitchen? // To track the selected kitchen
    @State private var showDetail = false // To control navigation to KitchenDetailView

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    ForEach(sampleKitchens) { kitchen in
                        // Convert GeoPoint to CLLocationCoordinate2D
                        let coordinate = CLLocationCoordinate2D(latitude: kitchen.location.latitude, longitude: kitchen.location.longitude)
                        
                        Annotation(kitchen.name, coordinate: coordinate) {
                            Button(action: {
                                selectedKitchen = kitchen
                                showDetail = true
                            }) {
                                VStack {
                                    // Load the kitchen's image
                                    AsyncImage(url: URL(string: kitchen.imageUrl ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 3)
                                    } placeholder: {
                                        // Placeholder for loading or missing image
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
            }
            .navigationDestination(isPresented: $showDetail) {
                if let kitchen = selectedKitchen {
                    KitchenDetailView(kitchen: kitchen)
                }
            }
        }
    }
}
