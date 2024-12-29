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
            // Food item image
            foodItem.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow
            
            // Food item details
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)
                Text(foodItem.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Text("$\(foodItem.cost, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Spacer()
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
            FoodItemSheet(foodItem: foodItem, kitchenName: foodItem.kitchenName, isPresented: $showSheet)
                .presentationDetents([.large]) // Open the sheet fully by default
        }
    }
}
