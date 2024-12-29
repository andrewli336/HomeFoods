//
//  CartSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/24/24.
//

import SwiftUI

struct CartSheet: View {
    @EnvironmentObject var cartManager: CartManager
    @Binding var showCartSheet: Bool
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            if showConfirmation {
                // Confirmation Screen
                OrderConfirmationView()
            } else {
                // Pre-calculate the total cost
                let totalCost: Double = cartManager.orders.reduce(0) { total, order in
                    total + order.totalCost
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text(cartManager.orders.first?.kitchenName ?? "Your Cart")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(cartManager.orders) { order in
                                HStack {
                                    order.foodItem.image
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(order.foodItem.name)
                                            .font(.headline)
                                        Text(order.foodItem.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("$\(order.foodItem.cost, specifier: "%.2f") x \(order.quantity)")
                                            .font(.subheadline)
                                    }
                                    Spacer()

                                    Button(action: {
                                        cartManager.removeOrder(order: order)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer()

                    VStack {
                        Divider()
                        HStack {
                            Text("Total")
                                .font(.title3)
                            Spacer()
                            Text("$\(totalCost, specifier: "%.2f")")
                                .font(.title3)
                                .bold()
                        }
                        .padding(.horizontal)

                        Button(action: {
                            showConfirmation = true
                        }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .navigationTitle("Your Cart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showCartSheet = false
                        }
                    }
                }
            }
        }
    }
}
