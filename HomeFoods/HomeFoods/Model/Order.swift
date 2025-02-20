//
//  Order.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore

struct OrderedFoodItem: Identifiable, Codable, Equatable {
    let id: String
    let foodItemId: String
    let name: String
    let quantity: Int
    let price: Double
    let imageUrl: String?
    let specialInstructions: String?
    let pickupTime: String?
    
    init(foodItemId: String, name: String, quantity: Int, price: Double, imageUrl: String?, specialInstructions: String?, pickupTime: String?) {
            self.id = UUID().uuidString  // Generate unique ID
            self.foodItemId = foodItemId // Store original food item ID
            self.name = name
            self.quantity = quantity
            self.price = price
            self.imageUrl = imageUrl
            self.specialInstructions = specialInstructions
            self.pickupTime = pickupTime
        }
}

struct Order: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let userId: String
    let kitchenId: String
    let kitchenName: String
    let datePlaced: Date
    var datePickedUp: Date?
    var orderedFoodItems: [OrderedFoodItem]
    let orderType: OrderType
    
    var totalCost: Double {
        orderedFoodItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.kitchenId == rhs.kitchenId &&
        lhs.kitchenName == rhs.kitchenName &&
        lhs.datePlaced == rhs.datePlaced &&
        lhs.datePickedUp == rhs.datePickedUp &&
        lhs.orderedFoodItems == rhs.orderedFoodItems &&
        lhs.orderType == rhs.orderType
    }
}

