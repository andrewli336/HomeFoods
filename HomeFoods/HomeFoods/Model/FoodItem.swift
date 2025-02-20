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
    @DocumentID var id: String? // Need this to be var, not let
    var name: String           // Changed to var
    var kitchenName: String    // Changed to var
    var kitchenId: String      // Changed to var
    var description: String?    // Changed to var
    var foodType: String       // Changed to var
    var rating: Double         // Changed to var
    var numRatings: Int        // Changed to var
    var cost: Double          // Changed to var
    var imageUrl: String?     // Changed to var
    var isFeatured: Bool      // Changed to var
    var numAvailable: Int     // Changed to var
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(kitchenId)
    }
    
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.kitchenId == rhs.kitchenId
    }
}
