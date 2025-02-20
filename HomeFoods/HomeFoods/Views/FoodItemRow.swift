//
//  FoodItemRow.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//
import SwiftUI


struct FoodItemRow: View {
    let foodItem: FoodItem
    @State private var showSheet = false // State to control sheet presentation

    var body: some View {
        HStack(spacing: 15) {
            // Food item details
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)
                Text(foodItem.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Text("$\(foodItem.cost, specifier: "%.2f") • \(Image(systemName: "hand.thumbsup")) \(Int(foodItem.rating))% (\(foodItem.numRatings))")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            ZStack {
                if let imageUrl = foodItem.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
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
                } else {
                    // Placeholder when no image URL exists
                    Color.gray
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .overlay(Text("No Image").foregroundColor(.white))
                }
                
                // White circle with a green plus sign
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 25, height: 25)
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .offset(x: -10, y: -10)
                    }
                }
            }
            .frame(width: 150, height: 150)
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
            FoodItemSheet(foodItem: foodItem, isPresented: $showSheet)
                .presentationDetents([.large]) // Open the sheet fully by default
        }
    }
}

#Preview {
    let sampleFood = sampleKitchens[0].foodItems[0]
    FoodItemRow(foodItem: sampleFood)

}
