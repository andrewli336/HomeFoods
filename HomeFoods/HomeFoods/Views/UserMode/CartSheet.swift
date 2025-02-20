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
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Binding var showCartSheet: Bool
    @State private var showConfirmation = false
    @State private var isPlacingOrder = false

    var body: some View {
        NavigationView {
            if showConfirmation {
                OrderConfirmationView(showCartSheet: $showCartSheet)
                    .onDisappear {
                        orderViewModel.resetCart()
                    }
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    Text(orderViewModel.cartOrder?.kitchenName ?? "Your Cart")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    // ✅ Order List
                    CartOrderListView()

                    Spacer()

                    // ✅ Checkout Section
                    CartCheckoutView(
                        totalCost: orderViewModel.cartOrder?.totalCost ?? 0,
                        isPlacingOrder: $isPlacingOrder,
                        placeOrder: placeOrder
                    )
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

        orderViewModel.placeOrder(userId: userId) { success in
            DispatchQueue.main.async {
                isPlacingOrder = false
                if success {
                    orderViewModel.clearCart() // ✅ Clear cart after successful order
                    showConfirmation = true
                } else {
                    print("❌ Failed to place order")
                }
            }
        }
    }
}

// ✅ Extracted Order List View
struct CartOrderListView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if let cartOrder = orderViewModel.cartOrder {
                    ForEach(cartOrder.orderedFoodItems) { foodItem in
                        CartOrderItemView(foodItem: foodItem)
                    }
                } else {
                    Text("Your cart is empty")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }
}

// ✅ Extracted Order Item Row
struct CartOrderItemView: View {
    let foodItem: OrderedFoodItem
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        HStack {
            if let imageUrl = foodItem.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .overlay(Text("N/A").foregroundColor(.white))
                    }
                }
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .overlay(Text("N/A").foregroundColor(.white))
            }

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
                orderViewModel.removeFromCart(foodItemId: foodItem.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
}

// ✅ Extracted Checkout View
struct CartCheckoutView: View {
    let totalCost: Double
    @Binding var isPlacingOrder: Bool
    let placeOrder: () -> Void

    var body: some View {
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
}
