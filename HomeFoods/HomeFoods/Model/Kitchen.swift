//
//  Kitchen.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import FirebaseFirestore
import SwiftUI
import MapKit

struct Kitchen: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let name: String
    let description: String
    let cuisine: String
    let rating: Double
    let location: GeoPoint // Use Firestore's GeoPoint
    let foodItems: [FoodItem] // Nested food items for simplicity
    let imageUrl: String? // URL to the kitchen's image in Firebase Storage
    let preorderSchedule: PreorderSchedule?
}
