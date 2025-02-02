//
//  ContentView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel

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
                    } else if appViewModel.isAdminMode {
                        Text("admin")
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
                                NavigationLink(destination: ProfileView()) {
                                    Text("View Profile")
                                }
                                NavigationLink(destination: SettingsView()) {
                                    Text("Settings")
                                }
                                Button("Logout", action: {
                                    appViewModel.logout()
                                })
                                
                                if let currentUser = appViewModel.currentUser {
                                    if currentUser.isChef {
                                        Divider()
                                        Toggle(isOn: Binding(
                                            get: { appViewModel.isChefMode },
                                            set: { newValue in
                                                if newValue {
                                                    appViewModel.isAdminMode = false
                                                }
                                                appViewModel.isChefMode = newValue
                                            }
                                        )) {
                                            HStack {
                                                Image(systemName: appViewModel.isChefMode ? "fork.knife.circle.fill" : "fork.knife.circle")
                                                    .foregroundColor(appViewModel.isChefMode ? .green : .gray)
                                                Text(appViewModel.isChefMode ? "Chef Mode: On" : "Switch to Chef Mode")
                                            }
                                        }
                                    }

                                    if currentUser.isAdmin {
                                        Divider()
                                        Toggle(isOn: Binding(
                                            get: { appViewModel.isAdminMode },
                                            set: { newValue in
                                                if newValue {
                                                    appViewModel.isChefMode = false
                                                }
                                                appViewModel.isAdminMode = newValue
                                            }
                                        )) {
                                            HStack {
                                                Image(systemName: appViewModel.isAdminMode ? "gear.circle.fill" : "gear.circle")
                                                    .foregroundColor(appViewModel.isAdminMode ? .blue : .gray)
                                                Text(appViewModel.isAdminMode ? "Admin Mode: On" : "Switch to Admin Mode")
                                            }
                                        }
                                    }
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
            if !orderViewModel.isCartEmpty() && !appViewModel.isChefMode {
                CartBar()
            }
        }
        .edgesIgnoringSafeArea(.bottom) // Ensure CartBar stays at the bottom
    }
    
}
