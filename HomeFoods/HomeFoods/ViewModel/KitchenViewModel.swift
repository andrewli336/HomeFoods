//
//  KitchenViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI
import FirebaseFirestore

class KitchenViewModel: ObservableObject {
    @Published var kitchens: [Kitchen] = []
    private let db = Firestore.firestore()

    func fetchKitchens() {
        db.collection("kitchens")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching kitchens: \(error.localizedDescription)")
                    return
                }

                self?.kitchens = snapshot?.documents.compactMap { try? $0.data(as: Kitchen.self) } ?? []
            }
    }

    func updateKitchen(_ kitchen: Kitchen) {
        guard let kitchenId = kitchen.id else { return }

        do {
            try db.collection("kitchens").document(kitchenId).setData(from: kitchen)
            print("Kitchen updated successfully")
        } catch {
            print("Error updating kitchen: \(error.localizedDescription)")
        }
    }
}
