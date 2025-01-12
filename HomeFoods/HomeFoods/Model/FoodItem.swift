//
//  FoodItem.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import Foundation
import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let kitchenName: String
    let description: String
    let foodType: String
    let rating: Double
    let numRatings: Int
    let cost: Double
    let image: Image
    let isFeatured: Bool
    let numAvailable: Int
    var specialInstructions: String? = nil // Optional instructions
}
