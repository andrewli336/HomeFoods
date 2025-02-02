//
//  OrderDetailView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/2/25.
//

import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        VStack {
            List {
                Section(header: Text("Order Details")) {
                    Text("Kitchen: \(order.kitchenName)")
                    Text("Placed on: \(formattedDate(order.datePlaced))")
                    Text("Status: \(order.datePickedUp == nil ? "In Progress" : "Completed")")
                }

                Section(header: Text("Items Ordered")) {
                    ForEach(order.orderedFoodItems, id: \.id) { foodItem in
                        HStack {
                            Text(foodItem.name)
                            Spacer()
                            Text("\(foodItem.quantity) x $\(foodItem.price, specifier: "%.2f")")
                            Text("$\(Double(foodItem.quantity) * foodItem.price, specifier: "%.2f")")
                                .bold()
                        }
                    }
                }
                
                Section(header: Text("Total")) {
                    Text("$\(order.totalCost, specifier: "%.2f")")
                        .font(.title)
                        .bold()
                }
            }
        }
        .navigationTitle("Order Details")
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
