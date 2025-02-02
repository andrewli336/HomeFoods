//
//  FoodItem.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct FoodItem: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let name: String
    let kitchenName: String
    let kitchenId: String
    let description: String
    let foodType: String
    let rating: Double
    let numRatings: Int
    let cost: Double
    let imageUrl: String // URL to the image in Firebase Storage
    let isFeatured: Bool
    let numAvailable: Int
}
