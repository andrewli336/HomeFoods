//
//  KitchenCard.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

struct KitchenCard: View {
    let kitchen: Kitchen
    @EnvironmentObject var locationManager: LocationManager // ✅ Get user's location
    @State private var distanceText: String = "Calculating..." // ✅ Store calculated distance

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Kitchen image using AsyncImage
            AsyncImage(url: URL(string: kitchen.imageUrl ?? "")) { phase in
                if let imageUrl = kitchen.imageUrl, !imageUrl.isEmpty {
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160) // Slightly taller for better visuals
                            .cornerRadius(15) // Rounded corners for the image
                            .clipped()
                    } else {
                        // 🔹 While loading, show a progress indicator
                        ProgressView()
                            .frame(height: 160)
                            .cornerRadius(15)
                    }
                } else {
                    // 🔹 If `imageUrl` is nil or empty, show a solid gray background
                    Color.gray.opacity(0.3)
                        .frame(height: 160)
                        .cornerRadius(15)
                }
            }
            
            // Kitchen details
            VStack(alignment: .leading, spacing: 8) {
                Text(kitchen.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(kitchen.cuisine) • \(kitchen.rating, specifier: "%.1f") ⭐")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(kitchen.foodItems.count) items available")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // ✅ Display distance
                Text(distanceText)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .bold()
            }
            .padding([.leading, .trailing, .bottom], 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            calculateDistance() // ✅ Calculate distance when card appears
        }
    }

    // 📌 **Function to Calculate Distance**
    private func calculateDistance() {
        guard let userLocation = locationManager.userLocation else {
            distanceText = "Location unavailable"
            return
        }
        
        let kitchenLocation = CLLocation(latitude: kitchen.location.latitude, longitude: kitchen.location.longitude)
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        let distanceInMeters = userCLLocation.distance(from: kitchenLocation)
        let distanceInMiles = distanceInMeters / 1609.34 // Convert to miles

        DispatchQueue.main.async {
            distanceText = String(format: "📍 %.1f miles away", distanceInMiles)
        }
    }
}
