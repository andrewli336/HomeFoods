//
//  ChefMenuView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//
import SwiftUI
import FirebaseFirestore

struct ChefMenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var kitchen: Kitchen? // Store the kitchen data
    @State private var isLoading = true
    @State private var isShowingFoodItemSheet = false
    @State private var selectedFoodItem: FoodItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let kitchen = kitchen {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            KitchenImageView(kitchen: kitchen)
                            
                            Text("Manage Your Menu")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(kitchen.foodItems) { item in
                                ChefFoodItemRow(foodItem: item, onEdit: { selectedItem in
                                    selectedFoodItem = selectedItem
                                    isShowingFoodItemSheet = true  // Add this line
                                }, onDelete: { itemId in
                                    deleteFoodItem(itemId: itemId)
                                })
                            }
                            
                            Button(action: {
                                selectedFoodItem = nil  // Clear any selected item
                                isShowingFoodItemSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add New Food Item")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                } else {
                    Text("❌ Failed to load kitchen data")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Manage Menu")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchChefKitchen()
            }
            .sheet(isPresented: $isShowingFoodItemSheet, onDismiss: {
                selectedFoodItem = nil  // Clear the selected item when sheet is dismissed
            }) {
                if let kitchen = kitchen {
                    EditFoodItemView(kitchen: kitchen, foodItem: selectedFoodItem) {
                        fetchChefKitchen()
                        isShowingFoodItemSheet = false
                    }
                }
            }
        }
    }

    /// **📌 Fetch the chef's kitchen**
    private func fetchChefKitchen() {
        guard let kitchenId = appViewModel.currentUser?.kitchenId else {
            print("❌ No kitchen ID found")
            isLoading = false
            return
        }

        appViewModel.fetchKitchenById(kitchenId: kitchenId) { fetchedKitchen in
            DispatchQueue.main.async {
                self.kitchen = fetchedKitchen
                self.isLoading = false
            }
        }
    }

    /// **📌 Delete a food item**
    private func deleteFoodItem(itemId: String) {
        guard let kitchenId = kitchen?.id else { return }

        appViewModel.deleteFoodItem(kitchenId: kitchenId, foodItemId: itemId) {
            fetchChefKitchen() // Refresh menu after deletion
        }
    }
}
