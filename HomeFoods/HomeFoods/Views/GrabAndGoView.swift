//
//  GrabAndGoView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct GrabAndGoView: View {
    let foodItems: [FoodItem]
    
    var body: some View {
        if foodItems.isEmpty {
            Text("No items available for Grab & Go.")
                .font(.subheadline)
                .foregroundColor(.gray)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(foodItems) { foodItem in
                    GrabAndGoFoodItemRow(foodItem: foodItem)
                }
            }
        }
    }
}
