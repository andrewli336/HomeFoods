//
//  CartView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        VStack {
            if orderViewModel.isCartEmpty() {
                Text("Your cart is empty!")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    if let order = orderViewModel.cartOrder {
                        Section(header: Text(order.kitchenName).font(.headline)) {
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
                    }
                }

                Spacer()

                Text("Total: $\(orderViewModel.cartOrder?.totalCost ?? 0, specifier: "%.2f")")
                    .font(.title)
                    .bold()
                    .padding()
            }
        }
        .navigationTitle("Your Cart")
    }
}
