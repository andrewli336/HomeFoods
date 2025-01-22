//
//  ChefMenuView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//
import SwiftUI
import FirebaseFirestore
import CoreLocation

struct ChefMenuView: View {
    // Properties for input fields
    @State private var kitchenName: String = ""
    @State private var kitchenDescription: String = ""
    @State private var kitchenCuisine: String = ""
    @State private var kitchenRating: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    // Firestore reference
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Kitchen")
                .font(.title)
                .bold()
            
            // Input fields
            TextField("Kitchen Name", text: $kitchenName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Kitchen Description", text: $kitchenDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Cuisine Type", text: $kitchenCuisine)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Rating (e.g., 4.5)", text: $kitchenRating)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            TextField("Latitude", text: $latitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            TextField("Longitude", text: $longitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            // Save button
            Button(action: addKitchen) {
                Text("Save Kitchen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Function to add a kitchen to Firestore
    private func addKitchen() {
        print("AddKitchen called") // Debug: Ensure the function is triggered
        
        guard let rating = Double(kitchenRating),
              let lat = Double(latitude),
              let lon = Double(longitude) else {
            print("Invalid input: Check fields")
            return
        }
        
        print("Valid input, preparing to save...") // Debug: Input validation passed
        
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
        
        db.collection("kitchens").addDocument(data: kitchenData) { error in
            if let error = error {
                print("Firestore error: \(error.localizedDescription)") // Debug Firestore errors
            } else {
                print("Kitchen added successfully!") // Debug success
                clearFields()
            }
        }
    }
    
    // Clear input fields after saving
    private func clearFields() {
        kitchenName = ""
        kitchenDescription = ""
        kitchenCuisine = ""
        kitchenRating = ""
        latitude = ""
        longitude = ""
    }
}

#Preview {
    ChefMenuView()
}
