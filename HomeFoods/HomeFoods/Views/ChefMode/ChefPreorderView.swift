//
//  ChefPreorderView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/19/25.
//

import SwiftUI

struct ChefPreorderView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var orders: [Order] = []
    @State private var isLoading = false
    @State private var viewMode: ViewMode = .foodMode
    
    enum ViewMode {
        case foodMode
        case orderMode
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    Text("Foods").tag(ViewMode.foodMode)
                    Text("Orders").tag(ViewMode.orderMode)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    if viewMode == .foodMode {
                        FoodModeView(orders: orders)
                    } else {
                        OrderModeView(orders: orders)
                    }
                }
            }
            .navigationTitle("Preorders")
            .onAppear {
                fetchOrders()
            }
        }
    }
    
    private func fetchOrders() {
        guard let kitchenId = appViewModel.currentUser?.kitchenId else { return }
        
        isLoading = true
        orderViewModel.fetchKitchenOrders(for: kitchenId) { fetchedOrders in
            DispatchQueue.main.async {
                // Only include preorders that haven't been picked up
                self.orders = fetchedOrders.filter {
                    $0.orderType == .preorder && $0.datePickedUp == nil
                }
                self.isLoading = false
            }
        }
    }
}

struct FoodModeView: View {
    let orders: [Order]
    
    // Group foods by time and aggregate quantities
    var foodsByTime: [(time: String, foods: [(name: String, quantity: Int, imageUrl: String?)])] {
        // First, collect all food items with their times
        var foodMap: [String: [(String, Int, String?)]] = [:]
        
        for order in orders {
            for item in order.orderedFoodItems {
                if let time = item.pickupTime {
                    let foods = foodMap[time] ?? []
                    // Check if food already exists for this time
                    if let index = foods.firstIndex(where: { $0.0 == item.name }) {
                        var updatedFoods = foods
                        updatedFoods[index].1 += item.quantity
                        foodMap[time] = updatedFoods
                    } else {
                        foodMap[time, default: []].append((item.name, item.quantity, item.imageUrl))
                    }
                }
            }
        }
        
        // Sort by time and convert to array
        return foodMap.map { (time: $0.key, foods: $0.value) }
            .sorted { $0.time < $1.time }
    }
    
    var body: some View {
        List {
            ForEach(foodsByTime, id: \.time) { timeGroup in
                Section(header: Text(timeGroup.time)) {
                    ForEach(timeGroup.foods, id: \.name) { food in
                        HStack {
                            if let imageUrl = food.imageUrl {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Color.gray
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
                            }
                            
                            Text(food.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("×\(food.quantity)")
                                .font(.title3)
                                .bold()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

struct OrderModeView: View {
    let orders: [Order]
    
    var sortedOrders: [Order] {
        orders.sorted { order1, order2 in
            // Sort by the earliest pickup time in each order
            let time1 = order1.orderedFoodItems.compactMap { $0.pickupTime }.min() ?? ""
            let time2 = order2.orderedFoodItems.compactMap { $0.pickupTime }.min() ?? ""
            return time1 < time2
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedOrders) { order in
                VStack(alignment: .leading, spacing: 8) {
                    // Order header
                    HStack {
                        Text("#\(order.id?.prefix(6) ?? "N/A")")
                            .font(.headline)
                        Spacer()
                        Text("$\(order.totalCost, specifier: "%.2f")")
                            .font(.headline)
                    }
                    
                    // Food items as bullet points
                    ForEach(order.orderedFoodItems) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(item.quantity)× \(item.name)")
                                if let time = item.pickupTime {
                                    Text(time)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                if let instructions = item.specialInstructions {
                                    Text(instructions)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
