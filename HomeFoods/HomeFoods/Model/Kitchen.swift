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
    var name: String
    var description: String
    var cuisine: String
    var rating: Double
    var location: GeoPoint // Use Firestore's GeoPoint
    var foodItems: [FoodItem] // Nested food items for simplicity
    var imageUrl: String? // URL to the kitchen's image in Firebase Storage
    var preorderSchedule: PreorderSchedule?
    var address: String?
}
