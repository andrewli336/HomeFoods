//
//  sampleKitchens.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseFirestore

let sampleKitchens = [
    // Chinese Cuisine
    Kitchen(
        name: "Happy & Healthy Kitchen",
        description: "Fresh and homemade Chinese food made with love by experienced chef Huifang.",
        cuisine: "Chinese",
        rating: 4.9,
        location: GeoPoint(latitude: 37.549099, longitude: -121.943069),
        foodItems: [
            FoodItem(
                id: "1",
                name: "Braised Beef Tendon",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Tender beef tendon braised in a savory soy-based sauce with aromatic spices.",
                foodType: "Main Course",
                rating: 95,
                numRatings: 16,
                cost: 12,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h1.JPG?alt=media&token=21e11e78-527b-488a-9d7e-14b2168a040b",
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                id: "2",
                name: "Rice Dumpling with Pork",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Sticky rice dumplings stuffed with seasoned pork and wrapped in bamboo leaves.",
                foodType: "Main Course",
                rating: 91,
                numRatings: 12,
                cost: 10,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h2.JPG?alt=media&token=b73ecdcf-8313-485d-b764-8ed555c211fd",
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                id: "3",
                name: "Sweet and Sour Ribs",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Juicy pork ribs coated in a sweet and tangy sauce with hints of vinegar.",
                foodType: "Main Course",
                rating: 89,
                numRatings: 9,
                cost: 8,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h3.JPG?alt=media&token=8c2c9569-3414-4f69-ac01-2b259c5dfc55",
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                id: "4",
                name: "Pearl Meatballs",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Delicious pork meatballs rolled in glutinous rice, steamed to perfection.",
                foodType: "Main Course",
                rating: 87,
                numRatings: 10,
                cost: 5,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h4.JPG?alt=media&token=614e159f-aa72-453a-b20e-951ab07e0712",
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                id: "5",
                name: "Banh Mi",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Vietnamese sandwich filled with pork, lettuce, and pickles.",
                foodType: "Main Course",
                rating: 90,
                numRatings: 14,
                cost: 10,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h5.JPG?alt=media&token=0b518350-9472-4cca-8613-2c6c025ea3e9",
                isFeatured: true,
                numAvailable: 5
            ),
            FoodItem(
                id: "6",
                name: "Braised Brisket",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Succulent beef brisket slow-cooked in a rich, flavorful broth.",
                foodType: "Main Course",
                rating: 88,
                numRatings: 11,
                cost: 8,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h6.JPG?alt=media&token=750d4665-8336-449c-aa84-b502be6237a4",
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                id: "7",
                name: "Braised Pork Belly",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Soft and flavorful pork belly braised in soy sauce and Chinese spices.",
                foodType: "Main Course",
                rating: 89,
                numRatings: 13,
                cost: 7,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h7.JPG?alt=media&token=7e0ac664-0f42-46b3-bb7c-544423af97ca",
                isFeatured: false,
                numAvailable: 5
            ),
            FoodItem(
                id: "8",
                name: "Crispy Belt Fish",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Lightly battered belt fish fried until golden and crispy, served with a dipping sauce.",
                foodType: "Main Course",
                rating: 85,
                numRatings: 8,
                cost: 6,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h8.JPG?alt=media&token=1c4dac19-18c9-4be3-8221-6816ae0527a7",
                isFeatured: false,
                numAvailable: 0
            ),
            FoodItem(
                id: "9",
                name: "Roasted Pork Feet",
                kitchenName: "Happy & Healthy Kitchen", kitchenId: "a",
                description: "Juicy pork feet roasted to crispy perfection with aromatic seasonings.",
                foodType: "Main Course",
                rating: 92,
                numRatings: 18,
                cost: 5,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h9.JPG?alt=media&token=e848cbcb-8fa7-41d2-b867-17c425c4c1d9",
                isFeatured: true,
                numAvailable: 3
            )
        ],
        imageUrl: "https://firebasestorage.googleapis.com/v0/b/homefoods-16e56.firebasestorage.app/o/h9.JPG?alt=media&token=e848cbcb-8fa7-41d2-b867-17c425c4c1d9", preorderSchedule: nil, address: "349"
    )
]


func uploadSampleKitchensToFirestore() {
    let db = Firestore.firestore()

    for kitchen in sampleKitchens {
        let kitchenRef = db.collection("kitchens").document() // 🔥 Generate unique kitchen ID
        let kitchenId = kitchenRef.documentID // Extract the generated ID

        // ✅ Create a structured Firestore document
        let newKitchen = [
            "name": kitchen.name,
            "description": kitchen.description,
            "cuisine": kitchen.cuisine,
            "rating": kitchen.rating,
            "location": [
                "latitude": kitchen.location.latitude,
                "longitude": kitchen.location.longitude
            ],
            "imageUrl": kitchen.imageUrl ?? "",
            "preorderSchedule": kitchen.preorderSchedule as Any,
            "address": kitchen.address
        ] as [String : Any]

        // ✅ Upload the kitchen WITHOUT foodItems (since they go in a subcollection)
        kitchenRef.setData(newKitchen) { error in
            if let error = error {
                print("❌ Error uploading kitchen \(kitchen.name): \(error.localizedDescription)")
                return
            }

            print("✅ Successfully uploaded kitchen: \(kitchen.name) with ID: \(kitchenId)")

            // ✅ Upload foodItems as a subcollection
            for foodItem in kitchen.foodItems {
                let foodItemRef = kitchenRef.collection("foodItems").document()

                let newFoodItem = [
                    "id": foodItemRef.documentID, // ✅ Firestore-generated ID
                    "name": foodItem.name,
                    "kitchenId": kitchenId, // ✅ Assign the correct kitchenId
                    "kitchenName": kitchen.name,
                    "description": foodItem.description,
                    "foodType": foodItem.foodType,
                    "rating": foodItem.rating,
                    "numRatings": foodItem.numRatings,
                    "cost": foodItem.cost,
                    "imageUrl": foodItem.imageUrl,
                    "isFeatured": foodItem.isFeatured,
                    "numAvailable": foodItem.numAvailable
                ] as [String : Any]

                foodItemRef.setData(newFoodItem) { error in
                    if let error = error {
                        print("❌ Error uploading food item \(foodItem.name): \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully uploaded food item: \(foodItem.name) under \(kitchen.name)")
                    }
                }
            }
        }
    }
}

