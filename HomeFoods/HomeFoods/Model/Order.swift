//
//  Order.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let userId: String // ID of the user who placed the order
    let kitchenId: String // Kitchen the order belongs to
    let kitchenName: String
    let datePlaced: Date // Date when the order was placed
    let datePickedUp: Date? // Optional, if not yet picked up
    var orderedFoodItems: [OrderedFoodItem] // Simplify FoodItem to OrderedFoodItem for order storage
    let orderType: OrderType
    var totalCost: Double {
        orderedFoodItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

struct OrderedFoodItem: Identifiable, Codable {
    let id: String // Food item ID
    let name: String
    let quantity: Int
    let price: Double
    let imageUrl: String
    var specialInstructions: String? = nil // Optional instructions
}

