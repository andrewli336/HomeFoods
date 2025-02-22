//
//  MenuManagementSection.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/22/25.
//

import SwiftUI

struct MenuManagementSection: View {
    let kitchen: Kitchen
    let onAddItem: () -> Void
    let onEditItem: (FoodItem) -> Void
    let onDeleteItem: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Manage Your Menu")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ForEach(kitchen.foodItems) { item in
                ChefFoodItemRow(
                    foodItem: item,
                    onEdit: { _ in onEditItem(item) },
                    onDelete: { _ in
                        if let id = item.id {
                            onDeleteItem(id)
                        }
                    }
                )
            }
            
            Button(action: onAddItem) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Food Item")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

