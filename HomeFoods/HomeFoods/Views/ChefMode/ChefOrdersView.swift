//
//  ChefOrdersView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct ChefOrdersView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var kitchenOrders: [Order] = [] // ✅ Stores fetched orders
    @State private var isLoading = false // ✅ Track loading state

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading orders...") // ✅ Show a loading indicator
                        .padding()
                } else if kitchenOrders.isEmpty {
                    Text("No orders yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    OrderListView(orders: kitchenOrders, refreshAction: fetchOrders) // ✅ Extracted list
                }
            }
            .navigationTitle("Manage Orders")
            .onAppear {
                fetchOrders()
            }
        }
    }

    /// ✅ Fetch orders for the current kitchen
    private func fetchOrders() {
        guard let kitchenId = appViewModel.currentUser?.kitchenId else {
            print("❌ No kitchen ID found for current user")
            return
        }

        isLoading = true
        orderViewModel.fetchKitchenOrders(for: kitchenId) { orders in
            DispatchQueue.main.async {
                self.kitchenOrders = orders
                self.isLoading = false
            }
        }
    }
}

/// ✅ Extracted Order List View
struct OrderListView: View {
    let orders: [Order]
    let refreshAction: () -> Void

    var body: some View {
        List {
            ForEach(orders) { order in
                OrderSectionView(order: order) // ✅ Extracted order section
            }
        }
        .refreshable {
            refreshAction()
        }
    }
}

struct OrderSectionView: View {
    let order: Order

    var body: some View {
        Section(header: Text("Order ID: \(order.id?.prefix(6) ?? "N/A")")) { // ✅ Safe Unwrapping
            ForEach(order.orderedFoodItems) { item in
                OrderItemRow(item: item)
            }

            Text("Order Type: \(order.orderType.rawValue)") // ✅ Ensure proper display
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }
}

/// ✅ Extracted Order Item Row
struct OrderItemRow: View {
    let item: OrderedFoodItem

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Color.gray
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.quantity) × $\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("$\(Double(item.quantity) * item.price, specifier: "%.2f")")
                .bold()
        }
        .padding(.vertical, 5)
    }
}
