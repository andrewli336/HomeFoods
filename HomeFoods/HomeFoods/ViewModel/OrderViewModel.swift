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
    @Published var cartOrder: Order? = nil // ✅ Only one cart order at a time

    private let db = Firestore.firestore()
    
    // ✅ Computed property: Current orders (Not yet picked up)
    var currentOrders: [Order] {
        userOrders.filter { $0.datePickedUp == nil }
    }

    // ✅ Computed property: Past orders (Already picked up)
    var pastOrders: [Order] {
        userOrders.filter { $0.datePickedUp != nil }
    }

    // ✅ Fetch orders for the user
    func fetchUserOrders(for userId: String) {
        db.collection("users").document(userId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching user orders: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self?.userOrders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
                    print("✅ Successfully fetched \(self?.userOrders.count ?? 0) orders")
                }
            }
    }
    
    func isCartEmpty() -> Bool {
        return cartOrder?.orderedFoodItems.isEmpty ?? true
    }

    // ✅ Add item to cart
    func addToCart(foodItem: FoodItem, quantity: Int, specialInstructions: String?) {
        guard let foodItemId = foodItem.id else {
            print("❌ Error: Food item does not have a valid ID")
            return
        }

        let newOrderedItem = OrderedFoodItem(
            id: foodItemId,
            name: foodItem.name,
            quantity: quantity,
            price: foodItem.cost,
            imageUrl: foodItem.imageUrl,
            specialInstructions: specialInstructions
        )

        DispatchQueue.main.async {
            if let existingOrder = self.cartOrder {
                // ✅ If new item is from a different kitchen, reset cart
                if existingOrder.kitchenId != foodItem.kitchenId {
                    print("🛒 New item from a different kitchen, clearing cart...")
                    self.cartOrder = Order(
                        id: UUID().uuidString, // Temporary ID
                        userId: "", // Set when user logs in
                        kitchenId: foodItem.kitchenId,
                        kitchenName: foodItem.kitchenName,
                        datePlaced: Date(),
                        datePickedUp: nil,
                        orderedFoodItems: [newOrderedItem],
                        orderType: .grabAndGo
                    )
                } else {
                    // ✅ Add to the existing order
                    self.cartOrder?.orderedFoodItems.append(newOrderedItem)
                }
            } else {
                // ✅ If no existing order, create a new one
                self.cartOrder = Order(
                    id: UUID().uuidString, // Temporary ID
                    userId: "", // Set when user logs in
                    kitchenId: foodItem.kitchenId,
                    kitchenName: foodItem.kitchenName,
                    datePlaced: Date(),
                    datePickedUp: nil,
                    orderedFoodItems: [newOrderedItem],
                    orderType: .grabAndGo
                )
            }

            print("✅ Added \(foodItem.name) to cart. Current total items: \(self.cartOrder?.orderedFoodItems.count ?? 0)")
        }
    }

    // ✅ Remove item from cart
    func removeFromCart(foodItemId: String) {
        DispatchQueue.main.async {
            self.cartOrder?.orderedFoodItems.removeAll { $0.id == foodItemId }

            // ✅ If no more items, reset cart
            if self.cartOrder?.orderedFoodItems.isEmpty == true {
                self.cartOrder = nil
            }
        }
    }

    // ✅ Clear cart after placing order
    func clearCart() {
        DispatchQueue.main.async {
            self.cartOrder = nil
        }
    }

    // ✅ Place order and save to Firestore
    func placeOrder(userId: String, completion: @escaping (Bool) -> Void) {
        guard let cartOrder = cartOrder else {
            print("❌ Error: No orders to place")
            completion(false)
            return
        }

        let orderRef = db.collection("orders").document()
        let orderId = orderRef.documentID

        let newOrder = Order(
            id: orderId, // Firestore-generated ID
            userId: userId,
            kitchenId: cartOrder.kitchenId,
            kitchenName: cartOrder.kitchenName,
            datePlaced: Date(),
            datePickedUp: nil,
            orderedFoodItems: cartOrder.orderedFoodItems,
            orderType: cartOrder.orderType
        )

        do {
            // ✅ Save order metadata
            try orderRef.setData(from: newOrder)
            try db.collection("users").document(userId).collection("orders").document(orderId).setData(from: newOrder)
            try db.collection("kitchens").document(cartOrder.kitchenId).collection("orders").document(orderId).setData(from: newOrder)

            // ✅ Save ordered items as a subcollection
            for item in cartOrder.orderedFoodItems {
                try orderRef.collection("orderedFoodItems").document(item.id).setData(from: item)
            }

            print("✅ Order placed successfully!")
            clearCart() // ✅ Empty cart after placing order
            completion(true)
        } catch {
            print("❌ Error placing order: \(error.localizedDescription)")
            completion(false)
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
