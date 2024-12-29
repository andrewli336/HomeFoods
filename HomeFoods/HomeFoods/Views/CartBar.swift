//
//  CartBar.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartBar: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCartSheet = false // State to control the sheet

    var body: some View {
        HStack {
            Text("Your Cart") // Placeholder, can dynamically display the restaurant name
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("$\(cartManager.orders.reduce(0) { $0 + $1.totalCost }, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 5) {
                Image(systemName: "cart.fill")
                    .foregroundColor(.white)
                Text("\(cartManager.orders.count)") // Item count
                    .foregroundColor(.white)
                    .padding(.leading, 5)
            }
            .padding(10)
            .background(Color.red)
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
            CartSheet(showCartSheet: $showCartSheet) // Pass the state to close the sheet
        }
    }
}
