//
//  ChefFoodItemRow.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/3/25.
//

import SwiftUI

struct ChefFoodItemRow: View {
    let foodItem: FoodItem
    let onEdit: (FoodItem) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: foodItem.imageUrl ?? "")) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Color.gray.frame(width: 60, height: 60)
            }

            VStack(alignment: .leading) {
                Text(foodItem.name)
                    .font(.headline)
                Text("$\(foodItem.cost, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // ✅ Edit Button
            Button(action: { onEdit(foodItem) }) {
                Image(systemName: "pencil")
                    .padding()
                    .background(Color.yellow.opacity(0.7))
                    .clipShape(Circle())
            }

            Button(action: {
                if let foodItemId = foodItem.id {
                    onDelete(foodItemId)
                } else {
                    print("❌ Error: Cannot delete food item without an ID.")
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
