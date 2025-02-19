//
//  FoodItem.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct FoodItem: Identifiable, Codable, Hashable {
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
    
    // Since we have a property wrapper (@DocumentID), we need to explicitly implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(kitchenId)
    }
    
    // Implement Equatable (required by Hashable)
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.kitchenId == rhs.kitchenId
    }
}
