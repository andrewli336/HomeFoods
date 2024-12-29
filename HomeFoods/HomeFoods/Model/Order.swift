//
//  Order.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct Order: Identifiable {
    let id = UUID()
    let foodItem: FoodItem
    let quantity: Int
    var totalCost: Double {
        return Double(quantity) * foodItem.cost
    }
    let specialInstructions: String? // Optional special instructions
    let kitchenName: String
}
