//
//  ContentView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager // Access the shared cart manager
    @State private var isChefMode: Bool = false // Tracks Chef Mode state

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView
            NavigationStack {
                TabView {
                    if isChefMode {
                        ChefDashboardView()
                            .tabItem {
                                Label("Dashboard", systemImage: "chart.bar.fill")
                            }
                        ChefMenuView()
                            .tabItem {
                                Label("Menu", systemImage: "list.bullet")
                            }
                        ChefOrdersView()
                            .tabItem {
                                Label("Orders", systemImage: "tray")
                            }
                    } else {
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
                .toolbar {
                    // Top-left: Home Icon, Text, and Dropdown
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.black)
                            Text(isChefMode ? "Kitchen" : "Home")
                                .font(.headline)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    // Handle address location management
                                    print("Manage location tapped")
                                }
                        }
                    }
                    
                    // Top-right: Notification Bell and Profile Picture
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        HStack(spacing: 15) {
                            // Notification Bell
                            Button(action: {
                                // Handle notifications
                                print("Notification tapped")
                            }) {
                                Image(systemName: "bell")
                                    .foregroundColor(.black)
                            }
                            
                            // Profile Dropdown
                            Menu {
                                Button("View Profile", action: {
                                    print("Navigate to Profile")
                                })
                                Button("Settings", action: {
                                    print("Navigate to Settings")
                                })
                                Button("Logout", action: {
                                    print("Handle Logout")
                                })
                                Divider() // Separator
                                Toggle(isOn: $isChefMode) {
                                    Text(isChefMode ? "Chef Mode: On" : "Switch to Chef Mode")
                                }
                                .onChange(of: isChefMode) {
                                    print(isChefMode ? "Switched to Chef Mode" : "Switched to User Mode")
                                }
                            } label: {
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "person")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                }
            }
            
            // Persistent CartBar (only for user mode)
            if !cartManager.orders.isEmpty && !isChefMode {
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
