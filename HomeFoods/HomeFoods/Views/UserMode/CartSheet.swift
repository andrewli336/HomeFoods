//
//  CartSheet.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/24/24.
//
import SwiftUI
import FirebaseFirestore

struct CartSheet: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appViewModel: AppViewModel // 🔥 Needed to fetch user ID
    @Binding var showCartSheet: Bool
    @State private var showConfirmation = false
    @State private var isPlacingOrder = false // Track loading state

    var body: some View {
        NavigationView {
            if showConfirmation {
                // ✅ Order Confirmation Screen
                OrderConfirmationView()
            } else {
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
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(order.foodItems) { foodItem in
                                        HStack {
                                            // 📌 Image placeholder (Replace with actual image logic)
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

                        // ✅ Place Order Button
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

    /// ✅ Places the order and saves it in Firestore
    private func placeOrder() {
        guard let userId = appViewModel.currentUser?.id else {
            print("❌ Error: User is not authenticated")
            return
        }

        guard let firstOrder = cartManager.orders.first else {
            print("❌ Error: No orders to place")
            return
        }

        isPlacingOrder = true // Show loading

        // ✅ Generate Firestore document ID before creating the order
        let orderRef = Firestore.firestore().collection("orders").document()
        let orderId = orderRef.documentID // 🔥 Ensure ID is assigned!

        // ✅ Debugging prints before creating order
        print("🔍 Debugging Order Details:")
        print("🆔 Generated Order ID: \(orderId)")
        print("👤 User ID: \(userId)")
        print("🏠 Kitchen ID: \(firstOrder.kitchenId ?? "❌ NIL!")")
        print("🍽 Kitchen Name: \(firstOrder.kitchenName)")
        print("📅 Date Placed: \(Date())")
        print("🍕 Food Items: \(firstOrder.foodItems.count) items")

        for item in firstOrder.foodItems {
            print("   🔹 Food Item: \(item.name), Qty: \(item.quantity), Price: \(item.price)")
        }

        let newOrder = Order(
            id: orderId, // ✅ Assign generated Firestore ID
            userId: userId,
            kitchenId: firstOrder.kitchenId, // 🔥 This might be nil—debug here!
            kitchenName: firstOrder.kitchenName,
            datePlaced: Date(),
            datePickedUp: nil,
            foodItems: firstOrder.foodItems,
            orderType: firstOrder.orderType
        )

        print("🛒 Attempting to place order with ID: \(orderId)")

        // ✅ Add order to Firestore
        appViewModel.orderViewModel.addOrder(order: newOrder) { success in
            DispatchQueue.main.async {
                isPlacingOrder = false
                if success {
                    print("✅ Order successfully placed!")
                    cartManager.clearCart() // ✅ Clear cart after successful order
                    showConfirmation = true // ✅ Show confirmation screen
                } else {
                    print("❌ Failed to place order")
                }
            }
        }
    }
}
