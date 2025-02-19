//
//  PreorderSchedule.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import Foundation
import FirebaseFirestore

struct PreorderSchedule: Codable {
    var dates: [String: [PreorderFood]] // Maps date string (yyyy-MM-dd) to foods
}

struct PreorderFood: Codable {
    var foodItemId: String
    var availableTimes: [String]
}

// Helper extension for Date to handle date string conversion
extension Date {
    var scheduleKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    static func fromScheduleKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}
