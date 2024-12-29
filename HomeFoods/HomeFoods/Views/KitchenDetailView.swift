//
//  KitchenDetailView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct KitchenDetailView: View {
    let kitchen: Kitchen
    @EnvironmentObject var cartManager: CartManager // Access cart data
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Kitchen image
                kitchen.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                    .cornerRadius(15) // Rounded corners for the image
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4) // Subtle shadow
                
                // Kitchen details
                VStack(alignment: .leading, spacing: 15) {
                    Text(kitchen.name)
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(2)
                    
                    Text("\(kitchen.cuisine) • \(kitchen.rating, specifier: "%.1f") ⭐")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(kitchen.description)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                        .padding(.top, 5)
                    
                    Divider() // Divider between details and food items
                    
                    Text("Available Food Items")
                        .font(.title2)
                        .bold()
                        .padding(.top, 10)
                    
                    ForEach(kitchen.foodItems) { foodItem in
                        FoodItemRow(foodItem: foodItem)
                            .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding([.leading, .trailing, .bottom], 15)
            }
        }
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all)) // Light background
        .navigationTitle(kitchen.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
