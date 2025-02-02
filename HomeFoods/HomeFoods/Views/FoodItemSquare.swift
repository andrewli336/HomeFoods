//
//  FoodItemSquare.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//
import SwiftUI

struct FoodItemSquare: View {
    let foodItem: FoodItem
    @State private var showSheet = false // State to control sheet presentation

    var body: some View {
        VStack(spacing: 15) {
            // Food item image (square)
            ZStack {
                // Food item image using AsyncImage
                AsyncImage(url: URL(string: foodItem.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .clipped()
                    } else if phase.error != nil {
                        // Placeholder for error
                        Color.red
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .overlay(Text("Error").foregroundColor(.white))
                    } else {
                        // Placeholder while loading
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                // White circle with a green plus sign
                VStack {
                    Spacer() // Push to the bottom
                    HStack {
                        Spacer() // Push to the right
                        ZStack {
                            Circle()
                                .fill(Color.white) // White circle background
                                .frame(width: 25, height: 25) // Circle size
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.black) // Green plus sign
                        }
                        .offset(x: -10, y: -10) // Adjust position slightly to align with bottom-right corner
                    }
                }
            }
            .frame(width: 150, height: 150) // Ensure the ZStack matches the image size

            // Food item details (left-aligned)
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)

                Text("$\(foodItem.cost, specifier: "%.2f") • \(Image(systemName: "hand.thumbsup")) \(Int(foodItem.rating))% (\(foodItem.numRatings))")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
        }
        .frame(width: 150, height: 188) // Adjust height to fit content
        .padding()
        .onTapGesture {
            showSheet = true // Show the sheet when tapped
        }
        .sheet(isPresented: $showSheet) {
            FoodItemSheet(foodItem: foodItem, isPresented: $showSheet) // Pass only required parameters
                .presentationDetents([.large]) // Open the sheet fully by default
        }
    }
}
