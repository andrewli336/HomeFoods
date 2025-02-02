//
//  OrderViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI
import FirebaseFirestore

class OrderViewModel: ObservableObject {
    @Published var userOrders: [Order] = [] // Orders specific to a user
    @Published var kitchenOrders: [Order] = [] // Orders specific to a kitchen

    private let db = Firestore.firestore()

    /// ✅ Fetches orders for a specific **user** (User Order History)
    func fetchUserOrders(for userId: String) {
        db.collection("users").document(userId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching user orders: \(error.localizedDescription)")
                    return
                }
                self?.userOrders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }

    /// ✅ Fetches orders for a specific **kitchen** (Kitchen Order Management)
    func fetchKitchenOrders(for kitchenId: String) {
        db.collection("kitchens").document(kitchenId).collection("orders")
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching kitchen orders: \(error.localizedDescription)")
                    return
                }
                self?.kitchenOrders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }

    func addOrder(order: Order, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()

        // ✅ Ensure order has a valid ID
        guard let orderId = order.id, !orderId.isEmpty else {
            print("❌ Error: Order ID is missing or empty!")
            completion(false)
            return
        }

        do {
            // ✅ Add order to global orders collection
            try db.collection("orders").document(orderId).setData(from: order)

            // ✅ Add order to user's order history
            try db.collection("users").document(order.userId).collection("orders").document(orderId)
                .setData(from: order)

            // ✅ Add order to kitchen's order list
            try db.collection("kitchens").document(order.kitchenId).collection("orders").document(orderId)
                .setData(from: order)

            print("✅ Order added successfully with ID: \(orderId)")
            completion(true)

        } catch {
            print("❌ Error adding order: \(error.localizedDescription)")
            completion(false)
        }
    }
}
