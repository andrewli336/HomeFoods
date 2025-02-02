//
//  OrdersView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationView {
            VStack {
                if orderViewModel.userOrders.isEmpty {
                    Text("You have no orders yet.")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        // 📌 Current Orders
                        if !orderViewModel.currentOrders.isEmpty {
                            Section(header: Text("Current Orders").font(.headline)) {
                                ForEach(orderViewModel.currentOrders, id: \.id) { order in
                                    NavigationLink(destination: OrderDetailView(order: order)) {
                                        OrderRowView(order: order)
                                    }
                                }
                            }
                        }

                        // 📌 Past Orders
                        if !orderViewModel.pastOrders.isEmpty {
                            Section(header: Text("Past Orders").font(.headline)) {
                                ForEach(orderViewModel.pastOrders, id: \.id) { order in
                                    NavigationLink(destination: OrderDetailView(order: order)) {
                                        OrderRowView(order: order)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Orders")
            .onAppear {
                if let userId = appViewModel.currentUser?.id {
                    orderViewModel.fetchUserOrders(for: userId) // Fetch latest orders
                }
            }
        }
    }
}
