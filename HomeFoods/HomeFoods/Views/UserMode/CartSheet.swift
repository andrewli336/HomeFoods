//
//  CartSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/24/24.
//
import SwiftUI
import FirebaseFirestore

struct CartSheet: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var showCartSheet: Bool
    @State private var showConfirmation = false
    @State private var isPlacingOrder = false

    var body: some View {
        NavigationView {
            if showConfirmation {
                OrderConfirmationView()
            } else {
                let totalCost: Double = appViewModel.orderViewModel.cartOrders.reduce(0) { total, order in
                    total + order.totalCost
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text(appViewModel.orderViewModel.cartOrders.first?.kitchenName ?? "Your Cart")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(appViewModel.orderViewModel.cartOrders) { order in
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(order.foodItems) { foodItem in
                                        HStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(8)

                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(foodItem.name)
                                                    .font(.headline)
                                                Text("$\(foodItem.price, specifier: "%.2f") x \(foodItem.quantity)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)

                                                if let instructions = foodItem.specialInstructions, !instructions.isEmpty {
                                                    Text("Special: \(instructions)")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            Spacer()

                                            Button(action: {
                                                appViewModel.orderViewModel.removeFromCart(order: order)
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
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

                        Button(action: placeOrder) {
                            HStack {
                                if isPlacingOrder {
                                    ProgressView()
                                }
                                Text("Place Order")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        .disabled(isPlacingOrder)
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

    private func placeOrder() {
        guard let userId = appViewModel.currentUser?.id else {
            print("❌ Error: User is not authenticated")
            return
        }

        isPlacingOrder = true

        appViewModel.orderViewModel.placeOrder(userId: userId) { success in
            DispatchQueue.main.async {
                isPlacingOrder = false
                if success {
                    appViewModel.orderViewModel.clearCart() // ✅ Clear cart after successful order
                    showConfirmation = true
                } else {
                    print("❌ Failed to place order")
                }
            }
        }
    }
}
