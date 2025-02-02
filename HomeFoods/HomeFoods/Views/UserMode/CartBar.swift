//
//  CartBar.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartBar: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var showCartSheet = false // Controls cart sheet visibility

    var body: some View {
        if let cartOrder = orderViewModel.cartOrder {
            HStack {
                Text(cartOrder.kitchenName) // ✅ Show kitchen name
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("$\(cartOrder.totalCost, specifier: "%.2f")") // ✅ Show total cost
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 5) {
                    Image(systemName: "cart.fill")
                        .foregroundColor(.white)
                    Text("\(cartOrder.orderedFoodItems.count)") // ✅ Show item count
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                }
                .padding(10)
                .background(Color.green)
                .cornerRadius(20)
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .cornerRadius(25) // Rounded rectangle
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3) // Floating shadow
            .padding(.horizontal, 16) // Padding from screen edges
            .padding(.bottom, 85) // Spacing above the tabs
            .onTapGesture {
                showCartSheet = true // Show the cart sheet when tapped
            }
            .sheet(isPresented: $showCartSheet) {
                CartSheet(showCartSheet: $showCartSheet) // ✅ Open CartSheet
            }
        }
    }
}
