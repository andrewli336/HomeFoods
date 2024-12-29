//
//  FoodItemSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct FoodItemSheet: View {
    let foodItem: FoodItem
    let kitchenName: String // Add the kitchen name as a property
    @EnvironmentObject var cartManager: CartManager // Access CartManager
    @Binding var isPresented: Bool // Control sheet visibility
    @State private var quantity: Int = 1
    @State private var specialInstructions: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Food image
            foodItem.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            
            // Title and description
            VStack(alignment: .leading, spacing: 10) {
                Text(foodItem.name)
                    .font(.title)
                    .bold()
                Text(foodItem.description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Divider()

            // Preferences
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferences")
                    .font(.headline)
                TextField("Add Special Instructions", text: $specialInstructions)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            // Counter
            HStack {
                Button(action: {
                    if quantity > 1 { quantity -= 1 }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                }

                Text("\(quantity)")
                    .font(.title2)
                    .padding(.horizontal, 20)

                Button(action: {
                    quantity += 1
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
            .padding()

            Spacer()

            // Add to Order Button
            VStack {
                Divider()
                Button(action: {
                    cartManager.addOrder(
                        foodItem: foodItem,
                        quantity: quantity,
                        kitchenName: kitchenName, // Pass the kitchen name here
                        specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
                    )
                    isPresented = false // Close the sheet
                }) {
                    HStack {
                        Text("Add to Order")
                            .font(.headline)
                        Spacer()
                        Text("$\(Double(quantity) * foodItem.cost, specifier: "%.2f")")
                            .font(.headline)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .background(Color.white)
        }
    }
}
