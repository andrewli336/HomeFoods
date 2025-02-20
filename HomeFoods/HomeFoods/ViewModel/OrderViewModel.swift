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
    @Published var isCartCleared: Bool = false  // Add this new state

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

    func addToCart(
        foodItem: FoodItem,
        quantity: Int,
        specialInstructions: String?,
        orderType: OrderType = .grabAndGo,
        pickupTime: String? = nil
    ) {
        guard let foodItemId = foodItem.id else {
            print("❌ Error: Food item does not have a valid ID")
            return
        }

        let newOrderedItem = OrderedFoodItem(
            foodItemId: foodItemId,  // Pass the original food item ID
            name: foodItem.name,
            quantity: quantity,
            price: foodItem.cost,
            imageUrl: foodItem.imageUrl,
            specialInstructions: specialInstructions,
            pickupTime: pickupTime
        )
        // Note: The OrderedFoodItem init will automatically generate a UUID for the id property

        DispatchQueue.main.async {
            if let existingOrder = self.cartOrder {
                // Check if new item is from a different kitchen
                if existingOrder.kitchenId != foodItem.kitchenId {
                    print("🛒 New item from a different kitchen, clearing cart...")
                    self.cartOrder = Order(
                        id: UUID().uuidString,
                        userId: "",
                        kitchenId: foodItem.kitchenId,
                        kitchenName: foodItem.kitchenName,
                        datePlaced: Date(),
                        datePickedUp: nil,
                        orderedFoodItems: [newOrderedItem],
                        orderType: orderType
                    )
                } else if existingOrder.orderType != orderType {
                    print("❌ Cannot mix different order types in the same cart")
                    return
                } else {
                    // Add to the existing order
                    self.cartOrder?.orderedFoodItems.append(newOrderedItem)
                }
            } else {
                // If no existing order, create a new one
                self.cartOrder = Order(
                    id: UUID().uuidString,
                    userId: "",
                    kitchenId: foodItem.kitchenId,
                    kitchenName: foodItem.kitchenName,
                    datePlaced: Date(),
                    datePickedUp: nil,
                    orderedFoodItems: [newOrderedItem],
                    orderType: orderType
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

    
    
    func clearCart() {
        isCartCleared = true  // Set this flag instead of clearing cartOrder
        // Only clear cartOrder when returning to the main view
    }
    
    func resetCart() {
        cartOrder = nil
        isCartCleared = false
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

    func fetchKitchenOrders(for kitchenId: String, completion: @escaping ([Order]) -> Void) {
        db.collection("kitchens").document(kitchenId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching kitchen orders: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let orders: [Order] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    
                    // Extract order fields
                    let id = doc.documentID
                    let kitchenId = data["kitchenId"] as? String ?? "Unknown"
                    let kitchenName = data["kitchenName"] as? String ?? "Unknown"
                    let userId = data["userId"] as? String ?? "Unknown"
                    let datePlaced = (data["datePlaced"] as? Timestamp)?.dateValue() ?? Date()
                    let datePickedUp = (data["datePickedUp"] as? Timestamp)?.dateValue()
                    
                    // Parse order type
                    let orderTypeString = data["orderType"] as? String ?? "grabAndGo"
                    let orderType: OrderType = {
                        switch orderTypeString {
                        case "preorder":
                            return .preorder
                        case "request":
                            return .request
                        default:
                            return .grabAndGo
                        }
                    }()

                    // Extract ordered food items with pickup time
                    let orderedFoodItemsData = data["orderedFoodItems"] as? [[String: Any]] ?? []
                    let orderedFoodItems: [OrderedFoodItem] = orderedFoodItemsData.map { itemData in
                        guard let id = itemData["id"] as? String,
                              let name = itemData["name"] as? String,
                              let price = itemData["price"] as? Double,
                              let quantity = itemData["quantity"] as? Int
                        else {
                            // Return a placeholder item if data is invalid
                            return OrderedFoodItem(
                                foodItemId: "invalid",
                                name: "Unknown Item",
                                quantity: 1,
                                price: 0,
                                imageUrl: nil,
                                specialInstructions: nil,
                                pickupTime: nil
                            )
                        }
                        
                        let imageUrl = itemData["imageUrl"] as? String
                        let specialInstructions = itemData["specialInstructions"] as? String
                        let pickupTime = itemData["pickupTime"] as? String
                        
                        return OrderedFoodItem(
                            foodItemId: id,
                            name: name,
                            quantity: quantity,
                            price: price,
                            imageUrl: imageUrl,
                            specialInstructions: specialInstructions,
                            pickupTime: pickupTime
                        )
                    }

                    return Order(
                        id: id,
                        userId: userId,
                        kitchenId: kitchenId,
                        kitchenName: kitchenName,
                        datePlaced: datePlaced,
                        datePickedUp: datePickedUp,
                        orderedFoodItems: orderedFoodItems,
                        orderType: orderType
                    )
                } ?? []

                completion(orders)
            }
    }
}
