//
//  PreorderFoodItemSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/19/25.
//

import SwiftUI

struct PreorderFoodItemSheet: View {
    let foodItem: FoodItem
    let availableTimes: [String]
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Binding var isPresented: Bool
    @State private var quantity: Int = 1
    @State private var specialInstructions: String = ""
    @State private var selectedTime: String?

    var body: some View {
        VStack(spacing: 20) {
            // Food Image
            if let imageUrl = foodItem.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
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
            } else {
                Color.gray
                    .frame(height: 200)
                    .overlay(Text("No image available").foregroundColor(.white))
            }

            // Title and Description
            VStack(alignment: .leading, spacing: 10) {
                Text(foodItem.name)
                    .font(.title)
                    .bold()
                Text(foodItem.description ?? "")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Divider()

            // Pickup Time Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Pickup Time")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableTimes, id: \.self) { time in
                            Button(action: {
                                selectedTime = time
                            }) {
                                Text(time)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedTime == time ? Color.red : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedTime == time ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)

            // Special Instructions
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferences")
                    .font(.headline)
                TextField("Add Special Instructions", text: $specialInstructions)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            // Quantity Selector
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
                    orderViewModel.addToCart(
                        foodItem: foodItem,
                        quantity: quantity,
                        specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions,
                        orderType: .preorder,
                        pickupTime: selectedTime
                    )
                    isPresented = false
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
                    .background(selectedTime != nil ? Color.red : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(selectedTime == nil)
                .padding(.horizontal)
            }
            .background(Color.white)
        }
    }
}
