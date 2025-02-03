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
    var location: GeoPoint
    var foodItems: [FoodItem]
    var imageUrl: String?
    var preorderSchedule: PreorderSchedule?
    var address: String?
    var ownerId: String
    var dateSubmitted: Date? // ✅ When the kitchen was applied
    var dateApproved: Date? // ✅ When the kitchen was approved
}
