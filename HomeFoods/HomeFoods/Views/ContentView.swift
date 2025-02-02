//
//  ContentView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager // Access the shared cart manager
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView
            NavigationStack {
                TabView {
                    if appViewModel.isChefMode {
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
                            .environmentObject(appViewModel)
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
                        ExploreView()
                            .environmentObject(appViewModel)
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
                            Text(appViewModel.isChefMode ? "Kitchen" : "Home")
                                .font(.headline)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    appViewModel.showAddressSelection = true // ✅ Open AddressSelectionView
                                }
                                .sheet(isPresented: $appViewModel.showAddressSelection) {
                                    AddressSelectionView(selectedAddress: $appViewModel.selectedManualAddress)
                                        .environmentObject(appViewModel) // ✅ Pass environment object
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
                            
                            Menu {
                                NavigationLink(destination: ProfileView().environmentObject(appViewModel)) {
                                    Text("View Profile")
                                }
                                NavigationLink(destination: SettingsView().environmentObject(appViewModel)) {
                                    Text("Settings")
                                }
                                Button("Logout", action: {
                                    appViewModel.logout()
                                })
                                Divider() // Separator
                                Toggle(isOn: $appViewModel.isChefMode) {
                                    Text(appViewModel.isChefMode ? "Chef Mode: On" : "Switch to Chef Mode")
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
            if !cartManager.orders.isEmpty && !appViewModel.isChefMode {
                CartBar()
            }
        }
        .edgesIgnoringSafeArea(.bottom) // Ensure CartBar stays at the bottom
    }
    
}

#Preview {
    let cartManager = CartManager() // Initialize CartManager
    let appViewModel = AppViewModel()
    ContentView()
        .environmentObject(cartManager)
        .environmentObject(appViewModel)
}
