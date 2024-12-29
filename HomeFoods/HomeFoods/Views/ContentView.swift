//
//  ContentView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager // Access the shared cart manager

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView
            NavigationStack {

                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    ExploreView()
                        .tabItem {
                            Label("Explore", systemImage: "map")
                        }
                    
                    OrdersView()
                        .tabItem {
                            Label("Orders", systemImage: "bag")
                        }
                }
            }
            
            // Persistent CartBar
            if !cartManager.orders.isEmpty {
                CartBar()
            }
        }
        .edgesIgnoringSafeArea(.bottom) // Ensure CartBar stays at the bottom
    }
}

#Preview {
    let cartManager = CartManager() // Initialize CartManager
    ContentView()
        .environmentObject(cartManager)
}
