//
//  ExploreView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import MapKit

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
                        Annotation(kitchen.name, coordinate: kitchen.location) {
                            Button(action: {
                                selectedKitchen = kitchen
                                showDetail = true
                            }) {
                                VStack {
                                    kitchen.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 3)
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
