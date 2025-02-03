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
    
    /// ✅ Fetches all kitchens from Firestore
    func fetchKitchens() {
        db.collection("kitchens").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch kitchens: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("❌ No kitchens found in Firestore")
                return
            }

            DispatchQueue.main.async {
                self.kitchens = documents.map { document in
                    let data = document.data()
                    
                    // ✅ Extract basic kitchen info
                    let id = document.documentID
                    let name = data["name"] as? String ?? "Unnamed Kitchen"
                    let description = data["description"] as? String ?? "No description"
                    let cuisine = data["cuisine"] as? String ?? "Unknown"
                    let rating = data["rating"] as? Double ?? 0.0
                    let imageUrl = data["imageUrl"] as? String
                    let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                    let address = data["address"] as? String
                    let ownerId = data["ownerId"] as? String ?? "Unknown"

                    // ✅ Create empty kitchen (we will add foodItems separately)
                    let kitchen = Kitchen(
                        id: id,
                        name: name,
                        description: description,
                        cuisine: cuisine,
                        rating: rating,
                        location: location,
                        foodItems: [], // 🔥 Will be fetched separately
                        imageUrl: imageUrl,
                        preorderSchedule: nil,
                        address: address,
                        ownerId: ownerId
                    )

                    // 🔥 Fetch foodItems separately
                    self.fetchFoodItems(for: kitchen)

                    return kitchen
                }
            }
        }
    }
    
    func fetchFoodItems(for kitchen: Kitchen) {
        guard let kitchenId = kitchen.id else {
            print("❌ Error: Kitchen ID is nil, cannot fetch food items.")
            return
        }

        let foodItemsRef = db.collection("kitchens").document(kitchenId).collection("foodItems")
        
        foodItemsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch food items for \(kitchen.name): \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No food items found for \(kitchen.name)")
                return
            }

            DispatchQueue.main.async {
                let foodItems: [FoodItem] = documents.compactMap { doc -> FoodItem? in
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
                        print("❌ Failed to parse food item for \(kitchen.name)")
                        return nil // ✅ Explicitly return nil as FoodItem? type
                    }

                    return FoodItem(
                        id: id, name: name, kitchenName: kitchenName, kitchenId: kitchenId, description: description,
                        foodType: foodType, rating: rating, numRatings: numRatings,
                        cost: cost, imageUrl: imageUrl, isFeatured: isFeatured, numAvailable: numAvailable
                    )
                }
                
                // ✅ Update the kitchen in the kitchens list
                if let index = self.kitchens.firstIndex(where: { $0.id == kitchenId }) {
                    var updatedKitchen = self.kitchens[index] // Create a mutable copy
                    updatedKitchen.foodItems = foodItems // Update the food items
                    self.kitchens[index] = updatedKitchen // Replace the old kitchen object
                    print("✅ Loaded \(foodItems.count) food items for \(kitchen.name)")
                }
            }
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

        let newKitchenRef = db.collection("applyingKitchens").document() // ✅ Generate unique document ID
        let kitchenId = newKitchenRef.documentID // ✅ Store generated ID

        let applicationData: [String: Any] = [
            "id": kitchenId, // ✅ Explicitly store ID
            "ownerId": userId,
            "name": kitchenName,
            "description": kitchenDescription,
            "cuisine": kitchenCuisine,
            "address": kitchenAddress,
            "location": kitchenGeoPoint ?? GeoPoint(latitude: 0, longitude: 0), // ✅ Use real GeoPoint if available
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
                let data = doc.data() // ✅ Get raw Firestore data

                // ✅ Extract required fields safely
                let id = doc.documentID
                let name = data["name"] as? String ?? "Unknown Kitchen"
                let description = data["description"] as? String ?? "No description available"
                let cuisine = data["cuisine"] as? String ?? "Unknown Cuisine"
                let rating = data["rating"] as? Double ?? 0.0
                let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let address = data["address"] as? String ?? "No Address"
                let ownerId = data["ownerId"] as? String ?? "Unknown Owner"
                
                // ✅ Assign default values for missing fields
                let foodItems: [FoodItem] = [] // Default to an empty list
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
                    ownerId: ownerId
                )
            } ?? []

            completion(kitchens)
        }
    }
    
    func approveKitchen(kitchenId: String, completion: @escaping (Bool) -> Void) {
        let applyingKitchenRef = db.collection("applyingKitchens").document(kitchenId)
        let approvedKitchenRef = db.collection("kitchens").document(kitchenId)

        applyingKitchenRef.getDocument { document, error in
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

            let data = document.data() ?? [:] // ✅ Get raw Firestore data

            // ✅ Extract required fields safely
            let name = data["name"] as? String ?? "Unknown Kitchen"
            let description = data["description"] as? String ?? "No description available"
            let cuisine = data["cuisine"] as? String ?? "Unknown Cuisine"
            let rating = data["rating"] as? Double ?? 0.0
            let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
            let address = data["address"] as? String ?? "No Address"
            let ownerId = data["ownerId"] as? String ?? "Unknown Owner"

            // ✅ Default placeholders for missing attributes
            let foodItems: [String: Any] = [:] // Empty subcollection (created separately)
            let imageUrl: String? = nil
            let preorderSchedule: [String: Any]? = nil

            // ✅ Kitchen object ready for insertion
            let kitchenData: [String: Any] = [
                "id": kitchenId,
                "name": name,
                "description": description,
                "cuisine": cuisine,
                "rating": rating,
                "location": location,
                "address": address,
                "ownerId": ownerId,
                "foodItems": foodItems, // 🔹 Empty dictionary (Subcollection will be created)
                "imageUrl": imageUrl as Any,
                "preorderSchedule": preorderSchedule as Any
            ]

            // ✅ Move kitchen to "kitchens" collection
            approvedKitchenRef.setData(kitchenData) { error in
                if let error = error {
                    print("❌ Error adding approved kitchen: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // ✅ Create empty "foodItems" subcollection
                approvedKitchenRef.collection("foodItems").document("placeholder").setData(["name": "Sample Item"]) { error in
                    if let error = error {
                        print("❌ Failed to initialize foodItems subcollection: \(error.localizedDescription)")
                    } else {
                        print("✅ Empty foodItems subcollection initialized")
                    }
                }

                // ✅ Remove from "applyingKitchens"
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
}
