//
//  PreorderSchedule.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import Foundation
import FirebaseFirestore

struct PreorderSchedule: Codable {
    let days: [String: [PreorderFood]] // Maps Weekday.rawValue to foods
}
// Represents a specific day in the preorder schedule
struct PreorderDay {
    let day: Weekday
    let foods: [PreorderFood]
}

struct PreorderFood: Codable {
    let foodItemId: String // ID of the food item
    let availableTimes: [String] // Array of time slots (e.g., ["09:00-11:00", "13:00-15:00"])
}

enum Weekday: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var displayName: String {
        rawValue.capitalized
    }
}
