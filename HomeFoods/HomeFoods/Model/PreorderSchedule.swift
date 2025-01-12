//
//  PreorderSchedule.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import Foundation

// Represents a PreorderSchedule for a kitchen
struct PreorderSchedule {
    let days: [PreorderDay]?
}

// Represents a specific day in the preorder schedule
struct PreorderDay {
    let day: Weekday
    let foods: [PreorderFood]
}

// Represents a food item and its available times
struct PreorderFood {
    let foodItem: FoodItem
    let availableTimes: [TimeInterval] // Times represented in seconds since midnight
}

// Enum for days of the week
enum Weekday: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    // Get display name for the day
    var displayName: String {
        rawValue.capitalized
    }
}
