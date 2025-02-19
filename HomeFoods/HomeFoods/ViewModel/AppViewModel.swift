//
//  AppViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Account? = nil
    @Published var isChefMode: Bool = false
    @Published var isAdminMode: Bool = false
    @Published var showOnboarding: Bool = false
    @Published var showTutorialView: Bool = false
    @Published var showChefSetupView: Bool = false
    @Published var showAddressSelection: Bool = false
    @Published var selectedManualAddress: String? = nil // ✅ Stores manually selected address
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userAddress: String?
    @Published var kitchens: [Kitchen] = [] // ✅ Stores fetched kitchens
    private let locationManager = LocationManager()

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    var isAdmin: Bool {
        return currentUser?.isAdmin ?? false
    }

    init() {
        listenToAuthChanges()
    }
    
    func listenToAuthChanges() {
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.isAuthenticated = true
                self.fetchCurrentUser(uid: user.uid)
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    
    func getUserLocation() {
        locationManager.getCurrentLocation()
        userLocation = locationManager.userLocation
        userAddress = locationManager.address
    }

    // MARK: - Authentication
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self?.isAuthenticated = true
                self?.fetchCurrentUser(uid: user.uid)
                completion(.success(()))
            }
        }
    }

    func signUp(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                self?.checkIfAdmin(email: email) { isAdmin in
                    self?.createUserInFirestore(uid: user.uid, name: name, email: email, isAdmin: isAdmin)
                    self?.isAuthenticated = true
                    self?.fetchCurrentUser(uid: user.uid)
                    self?.showOnboarding = true
                    completion(.success(()))
                }
            }
        }
    }
    
    // ✅ Function to check if an email is in the admin list
    private func checkIfAdmin(email: String, completion: @escaping (Bool) -> Void) {
        let adminRef = db.collection("config").document("adminEmails")
        
        adminRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching admin list: \(error.localizedDescription)")
                completion(false) // Assume not an admin if there's an error
                return
            }
            
            if let data = document?.data(), let emails = data["emails"] as? [String] {
                completion(emails.contains(email)) // ✅ Check if email is in the admin list
            } else {
                completion(false) // Assume not an admin if there's no data
            }
        }
    }


    func logout() {
        do {
            try auth.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
            self.isAdminMode = false
            self.isChefMode = false
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Firestore User Management
    private func fetchCurrentUser(uid: String) {
        db.collection("accounts").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Failed to fetch user: \(error.localizedDescription)")
            } else if let snapshot = snapshot, snapshot.exists {
                do {
                    let user = try snapshot.data(as: Account.self)
                    DispatchQueue.main.async {
                        self?.currentUser = user
                        self?.isChefMode = user.isChef
                    }
                } catch {
                    print("Failed to decode user: \(error.localizedDescription)")
                }
            } else {
                print("User document does not exist.")
            }
        }
    }
    
    func fetchAccount(ownerId: String, completion: @escaping (Account?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("accounts").document(ownerId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching account: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = snapshot, document.exists else {
                print("❌ No account found for ownerId: \(ownerId)")
                completion(nil)
                return
            }
            
            do {
                let account = try document.data(as: Account.self)
                completion(account)
            } catch {
                print("❌ Error decoding account: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func fetchKitchens(completion: @escaping () -> Void = {}) {
        db.collection("kitchens").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch kitchens: \(error.localizedDescription)")
                completion()
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No kitchens found in Firestore")
                completion()
                return
            }

            var fetchedKitchens: [Kitchen] = [] // ✅ Temporary list to hold fetched kitchens
            let dispatchGroup = DispatchGroup() // ✅ Ensure all async fetches complete

            for document in documents {
                let data = document.data()

                let id = document.documentID
                let name = data["name"] as? String ?? "Unnamed Kitchen"
                let description = data["description"] as? String ?? "No description"
                let cuisine = data["cuisine"] as? String ?? "Unknown"
                let rating = data["rating"] as? Double ?? 0.0
                let imageUrl = data["imageUrl"] as? String
                let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let address = data["address"] as? String
                let ownerId = data["ownerId"] as? String ?? "Unknown"
                let dateSubmitted = (data["dateSubmitted"] as? Timestamp)?.dateValue()
                let dateApproved = (data["dateApproved"] as? Timestamp)?.dateValue()

                var kitchen = Kitchen(
                    id: id,
                    name: name,
                    description: description,
                    cuisine: cuisine,
                    rating: rating,
                    location: location,
                    foodItems: [], // 🔥 Placeholder until we fetch real food items
                    imageUrl: imageUrl,
                    preorderSchedule: nil,
                    address: address,
                    ownerId: ownerId,
                    dateSubmitted: dateSubmitted,
                    dateApproved: dateApproved
                )

                dispatchGroup.enter() // ✅ Track async task
                self.fetchFoodItems(for: id) { foodItems in
                    kitchen.foodItems = foodItems // ✅ Assign fetched foodItems
                    fetchedKitchens.append(kitchen)
                    dispatchGroup.leave() // ✅ Task done
                }
            }

            dispatchGroup.notify(queue: .main) { // ✅ Runs when ALL food items are fetched
                self.kitchens = fetchedKitchens
                completion()
            }
        }
    }
    
    func fetchFoodItems(for kitchenId: String, completion: @escaping ([FoodItem]) -> Void) {
        let foodItemsRef = db.collection("kitchens").document(kitchenId).collection("foodItems")

        foodItemsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch food items for kitchen \(kitchenId): \(error.localizedDescription)")
                completion([]) // ✅ Return empty list if error
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No food items found for kitchen \(kitchenId)")
                completion([])
                return
            }

            let foodItems: [FoodItem] = documents.compactMap { doc in
                let data = doc.data()

                guard
                    let id = doc.documentID as String?,
                    let name = data["name"] as? String,
                    let kitchenName = data["kitchenName"] as? String,
                    let kitchenId = data["kitchenId"] as? String,
                    let description = data["description"] as? String,
                    let foodType = data["foodType"] as? String,
                    let rating = data["rating"] as? Double,
                    let numRatings = data["numRatings"] as? Int,
                    let cost = data["cost"] as? Double,
                    let imageUrl = data["imageUrl"] as? String,
                    let isFeatured = data["isFeatured"] as? Bool,
                    let numAvailable = data["numAvailable"] as? Int
                else {
                    print("❌ Failed to parse food item for kitchen \(kitchenId)")
                    return nil
                }

                return FoodItem(
                    id: id,
                    name: name,
                    kitchenName: kitchenName,
                    kitchenId: kitchenId,
                    description: description,
                    foodType: foodType,
                    rating: rating,
                    numRatings: numRatings,
                    cost: cost,
                    imageUrl: imageUrl,
                    isFeatured: isFeatured,
                    numAvailable: numAvailable
                )
            }

            print("✅ Loaded \(foodItems.count) food items for kitchen \(kitchenId)")
            completion(foodItems)
        }
    }

    // ✅ Create user in Firestore with the correct `isAdmin` value
    private func createUserInFirestore(uid: String, name: String, email: String, isAdmin: Bool) {
        let account = Account(
            id: uid,
            name: name,
            email: email,
            profilePictureUrl: nil,
            accountCreationDate: Date(),
            isChef: false,
            wantsToBeChef: false,
            isAdmin: isAdmin, // ✅ Set based on Firestore check
            kitchenId: nil,
            address: nil
        )

        do {
            try db.collection("accounts").document(uid).setData(from: account)
            print("✅ User created in Firestore with isAdmin: \(isAdmin)")
        } catch {
            print("❌ Failed to create user in Firestore: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Onboarding Data
    func saveOnboardingData(favoriteCuisines: [String], howHeardAboutUs: String?, wantsToBeChef: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUser?.id else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])))
            return
        }

        let data: [String: Any] = [
            "favoriteCuisines": favoriteCuisines,
            "howHeardAboutUs": howHeardAboutUs ?? "",
            "wantsToBeChef": wantsToBeChef
        ]

        db.collection("accounts").document(userId).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Update the local currentUser object
                self.currentUser?.favoriteCuisines = favoriteCuisines
                self.currentUser?.howHeardAboutUs = howHeardAboutUs
                self.currentUser?.wantsToBeChef = wantsToBeChef
                completion(.success(()))
            }
        }
    }
    func completeOnboarding() {
        showOnboarding = false
        
        if currentUser?.wantsToBeChef == true {
            // If the user chose to be a chef, show the Chef Setup View instead of the tutorial
            showChefSetupView = true
        } else {
            // Otherwise, show the tutorial
            showTutorialView = true
        }
    }
    
    func completeTutorial() {
        showTutorialView = false
        isAuthenticated = true // Ensure the user is authenticated and navigates to the main app
    }
    
    
    func submitChefApplication(
        kitchenName: String,
        kitchenDescription: String,
        kitchenCuisine: String,
        kitchenAddress: String,
        kitchenGeoPoint: GeoPoint?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let userId = currentUser?.id else {
            completion(false)
            return
        }

        let newKitchenRef = db.collection("applyingKitchens").document()
        let kitchenId = newKitchenRef.documentID
        let dateSubmitted = Timestamp(date: Date()) // ✅ Add current timestamp

        let applicationData: [String: Any] = [
            "id": kitchenId,
            "ownerId": userId,
            "name": kitchenName,
            "description": kitchenDescription,
            "cuisine": kitchenCuisine,
            "address": kitchenAddress,
            "location": kitchenGeoPoint ?? GeoPoint(latitude: 0, longitude: 0),
            "dateSubmitted": dateSubmitted // ✅ Store date submitted
        ]

        newKitchenRef.setData(applicationData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to submit kitchen: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Kitchen submitted for approval!")
                    completion(true)
                }
            }
        }
    }
    
    func fetchPendingKitchens(completion: @escaping ([Kitchen]) -> Void) {
        db.collection("applyingKitchens").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching pending kitchens: \(error.localizedDescription)")
                completion([])
                return
            }

            let kitchens = snapshot?.documents.compactMap { doc -> Kitchen? in
                let data = doc.data()
                
                let id = doc.documentID
                let name = data["name"] as? String ?? "Unknown Kitchen"
                let description = data["description"] as? String ?? "No description available"
                let cuisine = data["cuisine"] as? String ?? "Unknown Cuisine"
                let rating = data["rating"] as? Double ?? 0.0
                let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let address = data["address"] as? String ?? "No Address"
                let ownerId = data["ownerId"] as? String ?? "Unknown Owner"
                let dateSubmitted = data["dateSubmitted"] as? Timestamp ?? Timestamp(date: Date()) // ✅ Default to now if missing
                
                let foodItems: [FoodItem] = []
                let imageUrl: String? = nil
                let preorderSchedule: PreorderSchedule? = nil

                return Kitchen(
                    id: id,
                    name: name,
                    description: description,
                    cuisine: cuisine,
                    rating: rating,
                    location: location,
                    foodItems: foodItems,
                    imageUrl: imageUrl,
                    preorderSchedule: preorderSchedule,
                    address: address,
                    ownerId: ownerId,
                    dateSubmitted: dateSubmitted.dateValue(), // ✅ Convert to Date
                    dateApproved: nil // ✅ Still pending
                )
            } ?? []

            completion(kitchens)
        }
    }
    
    func approveKitchen(kitchenId: String, completion: @escaping (Bool) -> Void) {
        let applyingKitchenRef = db.collection("applyingKitchens").document(kitchenId)
        let approvedKitchenRef = db.collection("kitchens").document(kitchenId)

        applyingKitchenRef.getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error fetching applying kitchen: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let document = document, document.exists else {
                print("❌ Applying kitchen not found.")
                completion(false)
                return
            }

            let data = document.data() ?? [:]

            let name = data["name"] as? String ?? "Unknown Kitchen"
            let description = data["description"] as? String ?? "No description available"
            let cuisine = data["cuisine"] as? String ?? "Unknown Cuisine"
            let rating = data["rating"] as? Double ?? 0.0
            let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
            let address = data["address"] as? String ?? "No Address"
            let ownerId = data["ownerId"] as? String ?? ""

            // ✅ Debug: Print ownerId to check if it exists
            print("ℹ️ Owner ID: \(ownerId)")

            // ✅ If ownerId is empty, stop execution
            if ownerId.isEmpty {
                print("❌ Error: Missing ownerId for kitchen \(kitchenId)")
                completion(false)
                return
            }

            let dateSubmitted = data["dateSubmitted"] as? Timestamp ?? Timestamp(date: Date())
            let dateApproved = Timestamp(date: Date()) // ✅ Store approval date

            let kitchenData: [String: Any] = [
                "id": kitchenId,
                "name": name,
                "description": description,
                "cuisine": cuisine,
                "rating": rating,
                "location": location,
                "address": address,
                "ownerId": ownerId,
                "dateSubmitted": dateSubmitted,
                "dateApproved": dateApproved // ✅ Store approval date
            ]

            // ✅ Move kitchen to "kitchens" collection
            approvedKitchenRef.setData(kitchenData) { error in
                if let error = error {
                    print("❌ Error adding approved kitchen: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                approvedKitchenRef.collection("foodItems").document("placeholder").setData(["name": "Sample Item"]) { error in
                    if let error = error {
                        print("❌ Failed to initialize foodItems subcollection: \(error.localizedDescription)")
                    } else {
                        print("✅ Empty foodItems subcollection initialized")
                    }
                }

                // ✅ Call updateUserToChef function instead of updating directly
                self.updateUserToChef(ownerId: ownerId, kitchenId: kitchenId) { success in
                    if !success {
                        completion(false)
                        return
                    }

                    print("✅ User \(ownerId) successfully updated to chef with kitchenId \(kitchenId)")

                    // ✅ Remove from "applyingKitchens" after user update is successful
                    applyingKitchenRef.delete { error in
                        if let error = error {
                            print("❌ Error removing kitchen from applyingKitchens: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("✅ Kitchen approved and moved to kitchens collection")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func updateUserToChef(ownerId: String, kitchenId: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("accounts").document(ownerId)

        // ✅ Fetch existing user data first (for debugging)
        userRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching user before update: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let document = document, document.exists else {
                print("❌ User document not found before updating!")
                completion(false)
                return
            }

            let existingData = document.data() ?? [:]
            print("🔥 Firestore User Data (Before Update):")
            for (key, value) in existingData {
                print("   🔹 \(key): \(value)")
            }

            // ✅ Now update `isChef` and `kitchenId`
            userRef.setData([
                "isChef": true,
                "kitchenId": kitchenId
            ], merge: true) { error in
                if let error = error {
                    print("❌ Error updating user isChef status and kitchenId: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                print("✅ Firestore successfully updated user \(ownerId) to chef")

                // ✅ Fetch and print ALL user document fields after updating
                userRef.getDocument { updatedDoc, err in
                    if let err = err {
                        print("❌ Error fetching updated user document: \(err.localizedDescription)")
                    } else if let updatedDoc = updatedDoc, updatedDoc.exists {
                        let updatedData = updatedDoc.data() ?? [:]
                        print("🔥 Firestore User Data (After Update):")
                        for (key, value) in updatedData {
                            print("   🔹 \(key): \(value)")
                        }
                    } else {
                        print("❌ No updated data found in user document")
                    }
                }

                completion(true)
            }
        }
    }
    
    func updateUserAddress(userId: String, newAddress: String) {
        let userRef = db.collection("accounts").document(userId)
        
        userRef.updateData(["address": newAddress]) { error in
            if let error = error {
                print("❌ Failed to update user address: \(error.localizedDescription)")
            } else {
                print("✅ User address updated successfully!")
                DispatchQueue.main.async {
                    self.currentUser?.address = newAddress // ✅ Update local state
                }
            }
        }
    }
    
    func fetchKitchenById(kitchenId: String, completion: @escaping (Kitchen?) -> Void) {
        let kitchenRef = db.collection("kitchens").document(kitchenId)

        kitchenRef.getDocument { document, error in
            if let error = error {
                print("❌ Failed to fetch kitchen \(kitchenId): \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("❌ No kitchen found with ID \(kitchenId)")
                completion(nil)
                return
            }

            let id = document.documentID
            let name = data["name"] as? String ?? "Unnamed Kitchen"
            let description = data["description"] as? String ?? "No description"
            let cuisine = data["cuisine"] as? String ?? "Unknown"
            let rating = data["rating"] as? Double ?? 0.0
            let imageUrl = data["imageUrl"] as? String
            let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
            let address = data["address"] as? String
            let ownerId = data["ownerId"] as? String ?? "Unknown"
            let dateSubmitted = (data["dateSubmitted"] as? Timestamp)?.dateValue()
            let dateApproved = (data["dateApproved"] as? Timestamp)?.dateValue()

            var kitchen = Kitchen(
                id: id,
                name: name,
                description: description,
                cuisine: cuisine,
                rating: rating,
                location: location,
                foodItems: [], // 🔥 Placeholder, food items will be fetched next
                imageUrl: imageUrl,
                preorderSchedule: nil,
                address: address,
                ownerId: ownerId,
                dateSubmitted: dateSubmitted,
                dateApproved: dateApproved
            )

            // 🔥 Fetch food items for the kitchen
            self.fetchFoodItems(for: kitchenId) { foodItems in
                kitchen.foodItems = foodItems
                completion(kitchen) // ✅ Return the fully populated kitchen
            }
        }
    }

    // 📌 Add a Food Item
    func addFoodItem(kitchenId: String, foodItem: FoodItem) {
        let foodItemsRef = db.collection("kitchens").document(kitchenId).collection("foodItems")

        var newFoodItem = foodItem
        let document = foodItemsRef.document() // ✅ Generates a new Firestore document
        newFoodItem.id = document.documentID // ✅ Assigns the Firestore-generated ID

        do {
            let foodItemData = try Firestore.Encoder().encode(newFoodItem)
            document.setData(foodItemData) { error in
                if let error = error {
                    print("❌ Failed to add food item: \(error.localizedDescription)")
                } else {
                    print("✅ Food item added successfully!")
                }
            }
        } catch {
            print("❌ Error encoding food item: \(error.localizedDescription)")
        }
    }

    // 📌 Update a Food Item
    func updateFoodItem(kitchenId: String, foodItem: FoodItem) {
        guard let foodItemId = foodItem.id else {
            print("❌ Error: Cannot update food item without an ID.")
            return
        }

        let foodItemRef = db.collection("kitchens").document(kitchenId).collection("foodItems").document(foodItemId)

        do {
            let foodItemData = try Firestore.Encoder().encode(foodItem)
            foodItemRef.setData(foodItemData, merge: true) { error in
                if let error = error {
                    print("❌ Failed to update food item: \(error.localizedDescription)")
                } else {
                    print("✅ Food item updated successfully!")
                }
            }
        } catch {
            print("❌ Error encoding food item: \(error.localizedDescription)")
        }
    }

    // 📌 Delete a Food Item
    func deleteFoodItem(kitchenId: String, foodItemId: String, completion: @escaping () -> Void) {
        db.collection("kitchens").document(kitchenId).collection("foodItems")
            .document(foodItemId).delete { error in
                if let error = error {
                    print("❌ Failed to delete food item: \(error.localizedDescription)")
                }
                completion()
            }
    }
    
    func updatePreorderSchedule(kitchenId: String, schedule: PreorderSchedule, completion: @escaping (Bool) -> Void) {
        let kitchenRef = db.collection("kitchens").document(kitchenId)
        
        do {
            let scheduleData = try Firestore.Encoder().encode(schedule)
            kitchenRef.updateData(["preorderSchedule": scheduleData]) { error in
                if let error = error {
                    print("❌ Failed to update preorder schedule: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Preorder schedule updated successfully!")
                    completion(true)
                }
            }
        } catch {
            print("❌ Error encoding preorder schedule: \(error.localizedDescription)")
            completion(false)
        }
    }

    func fetchPreorderSchedule(kitchenId: String, completion: @escaping (PreorderSchedule?) -> Void) {
        let kitchenRef = db.collection("kitchens").document(kitchenId)
        
        kitchenRef.getDocument { document, error in
            if let error = error {
                print("❌ Failed to fetch preorder schedule: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document,
                  let data = document.data(),
                  let scheduleData = data["preorderSchedule"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            do {
                let schedule = try Firestore.Decoder().decode(PreorderSchedule.self, from: scheduleData)
                completion(schedule)
            } catch {
                print("❌ Error decoding preorder schedule: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // Helper function to add food items to a specific date
    func addFoodToSchedule(kitchenId: String, date: Date, food: PreorderFood, completion: @escaping (Bool) -> Void) {
        fetchPreorderSchedule(kitchenId: kitchenId) { schedule in
            var updatedSchedule = schedule ?? PreorderSchedule(dates: [:])
            let dateKey = date.scheduleKey
            var foodsForDate = updatedSchedule.dates[dateKey] ?? []
            foodsForDate.append(food)
            updatedSchedule.dates[dateKey] = foodsForDate
            
            self.updatePreorderSchedule(kitchenId: kitchenId, schedule: updatedSchedule, completion: completion)
        }
    }
}
