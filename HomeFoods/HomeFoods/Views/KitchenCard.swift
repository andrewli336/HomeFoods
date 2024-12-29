//
//  KitchenCard.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct KitchenCard: View {
    let kitchen: Kitchen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Kitchen image
            kitchen.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 160) // Slightly taller for better visuals
                .clipped()
                .cornerRadius(15) // Rounded corners for the image
            
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
            }
            .padding([.leading, .trailing, .bottom], 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 15) // More consistent corner radius
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15) // Subtle border for clarity
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Soft shadow
    }
}
