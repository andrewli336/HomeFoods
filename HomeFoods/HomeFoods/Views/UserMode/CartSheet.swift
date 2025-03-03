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
                    .onDisappear() { // Change from onDisappear to onAppear
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

struct CartOrderItemView: View {
    let foodItem: OrderedFoodItem
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let imageUrl = foodItem.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        } else {
                            Color.gray.opacity(0.3)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                                .overlay(Text("N/A").foregroundColor(.white))
                        }
                    }
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(Text("N/A").foregroundColor(.white))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem.name)
                        .font(.headline)
                    
                    HStack {
                        Text("$\(foodItem.price, specifier: "%.2f") × \(foodItem.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("= $\(foodItem.price * Double(foodItem.quantity), specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                    if let pickupTime = foodItem.pickupTime {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.orange)
                            Text("Pickup at \(pickupTime)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()

                Button(action: {
                    orderViewModel.removeFromCart(foodItemId: foodItem.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            if let instructions = foodItem.specialInstructions, !instructions.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue)
                    Text(instructions)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
            
            Divider()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
