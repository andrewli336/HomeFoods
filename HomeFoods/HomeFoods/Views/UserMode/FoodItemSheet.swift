//
//  FoodItemSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct FoodItemSheet: View {
    let foodItem: FoodItem
    @EnvironmentObject var appViewModel: AppViewModel // ✅ Access OrderViewModel via AppViewModel
    @Binding var isPresented: Bool // ✅ Control sheet visibility
    @State private var quantity: Int = 1
    @State private var specialInstructions: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // 📌 Food Image
            AsyncImage(url: URL(string: foodItem.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else if phase.error != nil {
                    Color.red
                        .frame(height: 200)
                        .overlay(Text("Failed to load image").foregroundColor(.white))
                } else {
                    ProgressView()
                        .frame(height: 200)
                }
            }

            // 📌 Title and Description
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

            // 📌 Preferences
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferences")
                    .font(.headline)
                TextField("Add Special Instructions", text: $specialInstructions)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            // 📌 Quantity Selector
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

            // 📌 Add to Order Button
            VStack {
                Divider()
                Button(action: {
                    // ✅ Call `addToCart` with separate parameters instead of passing an `Order`
                    appViewModel.orderViewModel.addToCart(
                        foodItem: foodItem,
                        quantity: quantity,
                        kitchenId: foodItem.kitchenId,
                        kitchenName: foodItem.kitchenName,
                        specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
                    )
                    isPresented = false // ✅ Close the sheet
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

// ✅ Updated Preview
#Preview {
    let sampleFood = sampleKitchens[0].foodItems[0]
    FoodItemSheet(foodItem: sampleFood, isPresented: .constant(true))
        .environmentObject(AppViewModel()) // ✅ Use AppViewModel instead of CartManager
}
