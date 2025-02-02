//
//  CartManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

class CartManager: ObservableObject {
    @Published var orders: [Order] = []

    func addOrder(foodItem: FoodItem, quantity: Int, kitchenId: String, kitchenName: String, specialInstructions: String?) {
        guard let foodItemId = foodItem.id else {
            print("Error: Food item does not have a valid ID")
            return
        }

        let newOrder = Order(
            id: UUID().uuidString, // Non-optional ID for local orders
            userId: "", // Leave empty if the user isn't logged in yet
            kitchenId: kitchenId, // Not applicable for cart-level orders
            kitchenName: kitchenName,
            datePlaced: Date(),
            datePickedUp: nil,
            foodItems: [
                OrderedFoodItem(
                    id: foodItemId,
                    name: foodItem.name,
                    quantity: quantity,
                    price: foodItem.cost,
                    specialInstructions: specialInstructions // Pass special instructions here
                )
            ],
            orderType: .grabAndGo
        )
        orders.append(newOrder)
    }

    func removeOrder(order: Order) {
        orders.removeAll { $0.id == order.id }
    }
    
    // ✅ Function to add an order to the cart
    func addOrder(order: Order) {
        orders.append(order)
    }

    // ✅ Function to clear all items from the cart
    func clearCart() {
        orders.removeAll()
    }
}
