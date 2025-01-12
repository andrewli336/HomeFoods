//
//  RequestView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct RequestView: View {
    let foodItems: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(foodItems) { foodItem in
                FoodItemRow(foodItem: foodItem)
            }
        }
    }
}
