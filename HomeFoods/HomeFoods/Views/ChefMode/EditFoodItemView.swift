//
//  EditFoodItemView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/3/25.
//

import SwiftUI

struct EditFoodItemView: View {
    let kitchenId: String
    var foodItem: FoodItem?
    var onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var imageUrl = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Image URL", text: $imageUrl)
                }

                Button(action: saveFoodItem) {
                    Text(foodItem == nil ? "Add Food Item" : "Update Food Item")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle(foodItem == nil ? "Add Food Item" : "Edit Food Item")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .onAppear {
                if let foodItem = foodItem {
                    name = foodItem.name
                    description = foodItem.description
                    price = "\(foodItem.cost)"
                    imageUrl = foodItem.imageUrl ?? ""
                }
            }
        }
    }

    private func saveFoodItem() {
        guard let priceValue = Double(price) else { return }

        let newFoodItem = FoodItem(
            id: foodItem?.id ?? UUID().uuidString,
            name: name,
            kitchenName: "",
            kitchenId: kitchenId,
            description: description,
            foodType: "",
            rating: 0,
            numRatings: 0,
            cost: priceValue,
            imageUrl: imageUrl,
            isFeatured: false,
            numAvailable: 0
        )

        if foodItem == nil {
            AppViewModel().addFoodItem(kitchenId: kitchenId, foodItem: newFoodItem)
        } else {
            AppViewModel().updateFoodItem(kitchenId: kitchenId, foodItem: newFoodItem)
        }

        onSave()
        dismiss()
    }
}
