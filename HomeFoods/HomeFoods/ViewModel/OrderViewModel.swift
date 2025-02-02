//
//  OrderViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI
import FirebaseFirestore

class OrderViewModel: ObservableObject {
    @Published var userOrders: [Order] = [] // User's order history
    @Published var kitchenOrders: [Order] = [] // Kitchen's order history
    @Published var cartOrders: [Order] = [] {
        didSet { objectWillChange.send() } // ✅ Force UI update
    }


    private let db = Firestore.firestore()

    // ✅ Add item to cart
    func addToCart(foodItem: FoodItem, quantity: Int, kitchenId: String, kitchenName: String, specialInstructions: String?) {
        guard let foodItemId = foodItem.id else {
            print("❌ Error: Food item does not have a valid ID")
            return
        }

        let newOrder = Order(
            id: UUID().uuidString, // Temporary local ID
            userId: "", // Set when user logs in
            kitchenId: kitchenId,
            kitchenName: kitchenName,
            datePlaced: Date(),
            datePickedUp: nil,
            foodItems: [
                OrderedFoodItem(
                    id: foodItemId,
                    name: foodItem.name,
                    quantity: quantity,
                    price: foodItem.cost,
                    specialInstructions: specialInstructions
                )
            ],
            orderType: .grabAndGo
        )

        DispatchQueue.main.async { // ✅ Ensure UI update
            self.cartOrders.append(newOrder)
            print("🛒 Added \(foodItem.name) to cart. Total items: \(self.cartOrders.count)")
        }
    }

    // ✅ Remove order from cart
    func removeFromCart(order: Order) {
        cartOrders.removeAll { $0.id == order.id }
    }

    // ✅ Clear cart after placing order
    func clearCart() {
        cartOrders.removeAll()
    }

    // ✅ Place order and save to Firestore
    func placeOrder(userId: String, completion: @escaping (Bool) -> Void) {
        guard let firstOrder = cartOrders.first else {
            print("❌ Error: No orders to place")
            completion(false)
            return
        }

        let orderRef = db.collection("orders").document()
        let orderId = orderRef.documentID

        let newOrder = Order(
            id: orderId, // Firestore-generated ID
            userId: userId,
            kitchenId: firstOrder.kitchenId,
            kitchenName: firstOrder.kitchenName,
            datePlaced: Date(),
            datePickedUp: nil,
            foodItems: firstOrder.foodItems,
            orderType: firstOrder.orderType
        )

        do {
            try orderRef.setData(from: newOrder)
            try db.collection("users").document(userId).collection("orders").document(orderId).setData(from: newOrder)
            try db.collection("kitchens").document(firstOrder.kitchenId).collection("orders").document(orderId).setData(from: newOrder)

            print("✅ Order placed successfully!")
            clearCart() // Empty cart after placing order
            completion(true)
        } catch {
            print("❌ Error placing order: \(error.localizedDescription)")
            completion(false)
        }
    }

    // ✅ Fetch orders for user
    func fetchUserOrders(for userId: String) {
        db.collection("users").document(userId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching user orders: \(error.localizedDescription)")
                    return
                }
                self?.userOrders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }

    // ✅ Fetch orders for kitchen
    func fetchKitchenOrders(for kitchenId: String) {
        db.collection("kitchens").document(kitchenId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching kitchen orders: \(error.localizedDescription)")
                    return
                }
                self?.kitchenOrders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }
}
