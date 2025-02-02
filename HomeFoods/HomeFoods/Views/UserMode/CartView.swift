//
//  CartView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var appViewModel: AppViewModel // Access orderViewModel via appViewModel

    var body: some View {
        VStack {
            if appViewModel.orderViewModel.cartOrders.isEmpty {
                Text("Your cart is empty!")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(appViewModel.orderViewModel.cartOrders) { order in
                        Section(header: Text(order.kitchenName).font(.headline)) {
                            ForEach(order.foodItems) { foodItem in
                                HStack {
                                    Text(foodItem.name)
                                    Spacer()
                                    Text("\(foodItem.quantity) x $\(foodItem.price, specifier: "%.2f")")
                                    Text("$\(Double(foodItem.quantity) * foodItem.price, specifier: "%.2f")")
                                        .bold()
                                }
                            }
                        }
                    }
                }

                Spacer()

                Text("Total: $\(appViewModel.orderViewModel.cartOrders.reduce(0) { $0 + $1.totalCost }, specifier: "%.2f")")
                    .font(.title)
                    .bold()
                    .padding()
            }
        }
        .navigationTitle("Your Cart")
    }
}
