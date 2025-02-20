//
//  CartBar.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct CartBar: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showCartSheet = false
    @State private var isVisible = false // Local state for animation

    var body: some View {
        Group {
            if let cartOrder = orderViewModel.cartOrder {
                HStack {
                    Text(cartOrder.kitchenName)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("$\(cartOrder.totalCost, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.white)
                        Text("\(cartOrder.orderedFoodItems.count)")
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                    }
                    .padding(10)
                    .background(Color.green)
                    .cornerRadius(20)
                }
                .padding()
                .background(Color.red.opacity(0.9))
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                .padding(.horizontal, 16)
                .padding(.bottom, 85)
                .onTapGesture {
                    showCartSheet = true
                }
                .sheet(isPresented: $showCartSheet) {
                    CartSheet(showCartSheet: $showCartSheet)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 50)
            }
        }
        .animation(.spring(response: 0.3), value: isVisible)
        .onChange(of: orderViewModel.cartOrder) { newValue in
            withAnimation {
                isVisible = newValue != nil
            }
        }
    }
}
