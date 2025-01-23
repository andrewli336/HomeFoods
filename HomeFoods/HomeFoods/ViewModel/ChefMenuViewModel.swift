//
//  ChefMenuViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import FirebaseFirestore
import SwiftUI

class ChefMenuViewModel: ObservableObject {
    @Published var kitchenName: String = ""
    @Published var kitchenDescription: String = ""
    @Published var kitchenCuisine: String = ""
    @Published var kitchenRating: String = ""
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var isLoading: Bool = false // To indicate if a Firestore operation is in progress
    @Published var successMessage: String? = nil // To show success feedback
    @Published var errorMessage: String? = nil // To show error feedback
    
    private let db = Firestore.firestore()
    
    func addKitchen() {
        // Validate input
        guard let rating = Double(kitchenRating),
              let lat = Double(latitude),
              let lon = Double(longitude) else {
            errorMessage = "Invalid input: Please ensure all fields are filled out correctly."
            return
        }
        
        // Prepare the data to save
        let kitchenData: [String: Any] = [
            "name": kitchenName,
            "description": kitchenDescription,
            "cuisine": kitchenCuisine,
            "rating": rating,
            "location": GeoPoint(latitude: lat, longitude: lon),
            "foodItems": [],
            "imageUrl": "",
            "preorderSchedule": [:]
        ]
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Save the kitchen to Firestore
        db.collection("kitchens").addDocument(data: kitchenData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error adding kitchen: \(error.localizedDescription)"
                } else {
                    self?.successMessage = "Kitchen added successfully!"
                    self?.clearFields()
                }
            }
        }
    }
    
    private func clearFields() {
        kitchenName = ""
        kitchenDescription = ""
        kitchenCuisine = ""
        kitchenRating = ""
        latitude = ""
        longitude = ""
    }
}
