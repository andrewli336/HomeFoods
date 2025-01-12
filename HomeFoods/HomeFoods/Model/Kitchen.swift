//
//  Kitchen.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import Foundation
import SwiftUI
import MapKit

struct Kitchen: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let cuisine: String
    let rating: Double
    let location: CLLocationCoordinate2D
    let foodItems: [FoodItem]
    let image: Image
    let preorderSchedule: PreorderSchedule?
}
