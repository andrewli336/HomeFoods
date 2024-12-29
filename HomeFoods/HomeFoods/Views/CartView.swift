//
//  CartView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack {
            List(cartManager.orders) { order in
                HStack {
                    Text(order.foodItem.name)
                    Spacer()
                    Text("\(order.quantity) x $\(order.foodItem.cost, specifier: "%.2f")")
                    Text("$\(order.totalCost, specifier: "%.2f")")
                        .bold()
                }
            }
            
            Spacer()
            
            Text("Total: $\(cartManager.orders.reduce(0) { $0 + $1.totalCost }, specifier: "%.2f")")
                .font(.title)
                .bold()
                .padding()
        }
    }
}
