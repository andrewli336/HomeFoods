//
//  CartManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

class CartManager: ObservableObject {
    @Published var orders: [Order] = []

    func addOrder(foodItem: FoodItem, quantity: Int, kitchenName: String, specialInstructions: String?) {
        // Add to cart logic
        orders.append(Order(foodItem: foodItem, quantity: quantity, specialInstructions: specialInstructions, kitchenName: kitchenName))
    }

    func removeOrder(order: Order) {
        // Remove from cart logic
        orders.removeAll { $0.id == order.id }
    }
}

