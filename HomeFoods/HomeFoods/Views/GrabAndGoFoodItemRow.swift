//
//  GrabAndGoFoodItemRow.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct GrabAndGoFoodItemRow: View {
    let foodItem: FoodItem
    @State private var showSheet = false // State to control sheet presentation

    var body: some View {
        HStack(spacing: 15) {
            // Food item details
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)
                Text(foodItem.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Text("$\(foodItem.cost, specifier: "%.2f") • \(Image(systemName: "hand.thumbsup")) \(Int(foodItem.rating))% (\(foodItem.numRatings))")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                if foodItem.numAvailable > 0 {
                    Text("\(foodItem.numAvailable) available")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Out of stock")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            Spacer()
            
            ZStack {
                // Food item image using AsyncImage
                AsyncImage(url: URL(string: foodItem.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100) // Smaller size for less height
                            .cornerRadius(10)
                            .clipped()
                    } else if phase.error != nil {
                        // Placeholder for error
                        Color.red
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            .overlay(Text("Error").foregroundColor(.white))
                    } else {
                        // Placeholder while loading
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                }
                
                // Available count in the bottom-left corner of the image
                if foodItem.numAvailable > 0 {
                    Text("\(foodItem.numAvailable)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(5)
                        .offset(x: -35, y: 35) // Adjust position to bottom-left
                }
                
                // White circle with a green plus sign in the bottom-right corner
                VStack {
                    Spacer() // Push to the bottom
                    HStack {
                        Spacer() // Push to the right
                        ZStack {
                            Circle()
                                .fill(Color.white) // White circle background
                                .frame(width: 25, height: 25) // Circle size
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray) // Gray plus sign
                        }
                        .offset(x: -5, y: -5) // Adjust position slightly to align with bottom-right corner
                    }
                }
            }
            .frame(width: 100, height: 100) // Ensure the ZStack matches the image size
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .onTapGesture {
            showSheet = true // Show the sheet when tapped
        }
        .sheet(isPresented: $showSheet) {
            FoodItemSheet(foodItem: foodItem, isPresented: $showSheet) // Updated to match the FoodItemSheet initializer
                .presentationDetents([.large]) // Open the sheet fully by default
        }
    }
}
#Preview {
    let sampleFood = sampleKitchens[0].foodItems[0]
    GrabAndGoFoodItemRow(foodItem: sampleFood)
}
