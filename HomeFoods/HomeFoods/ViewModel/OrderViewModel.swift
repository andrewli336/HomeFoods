//
//  OrderViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI
import FirebaseFirestore

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    private let db = Firestore.firestore()

    func fetchOrders(for userId: String) {
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "datePlaced", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }

                self?.orders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
            }
    }

    func addOrder(order: Order, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("orders").addDocument(from: order) { error in
                if let error = error {
                    print("Error adding order: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Order added successfully")
                    completion(true)
                }
            }
        } catch {
            print("Error encoding order: \(error.localizedDescription)")
            completion(false)
        }
    }
}
