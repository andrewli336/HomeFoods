//
//  EditFoodItemView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/3/25.
//

import SwiftUI
import FirebaseStorage
import PhotosUI

struct EditFoodItemView: View {
    let kitchen: Kitchen
    var foodItem: FoodItem?
    var onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var imageUrl: String? = nil
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    
                    // Image picker with better visual feedback
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        VStack {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Uploading...")
                            } else if let imageUrl = imageUrl, !imageUrl.isEmpty {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Label("Select Image", systemImage: "photo.fill")
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .onChange(of: selectedImage) { newValue in
                        if let newValue {
                            print("📸 Image selected, starting upload...")
                            uploadImage(item: newValue)
                        }
                    }
                }

                Button(action: saveFoodItem) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text(foodItem == nil ? "Add Food Item" : "Update Food Item")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isUploading || name.isEmpty || description.isEmpty || price.isEmpty)
            }
            .navigationTitle(foodItem == nil ? "Add Food Item" : "Edit Food Item")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .onAppear {
                if let foodItem = foodItem {
                    name = foodItem.name
                    description = foodItem.description ?? ""
                    price = "\(foodItem.cost)"
                    imageUrl = foodItem.imageUrl ?? ""
                    print("📱 Loaded existing image URL: \(foodItem.imageUrl ?? "none")")
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveFoodItem() {
        guard let priceValue = Double(price),
              let kitchenId = kitchen.id else {
            errorMessage = "Invalid price or kitchen ID"
            showError = true
            return
        }

        print("💾 Saving food item with image URL: \(imageUrl ?? "none")")
        
        let newFoodItem = FoodItem(
            id: foodItem?.id ?? UUID().uuidString,
            name: name,
            kitchenName: kitchen.name,
            kitchenId: kitchen.id ?? "",
            description: description,
            foodType: kitchen.cuisine,
            rating: 0,
            numRatings: 0,
            cost: priceValue,
            imageUrl: imageUrl,
            isFeatured: false,
            numAvailable: 0
        )

        if foodItem == nil {
            AppViewModel().addFoodItem(kitchenId: kitchenId, foodItem: newFoodItem)
        } else {
            AppViewModel().updateFoodItem(kitchenId: kitchenId, foodItem: newFoodItem)
        }

        onSave()
        dismiss()
    }
    
    private func uploadImage(item: PhotosPickerItem) {
        isUploading = true
        print("🚀 Starting image upload process...")
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw URLError(.badServerResponse)
                }
                print("📦 Image data loaded, size: \(data.count) bytes")
                
                // Upload to Firebase Storage
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("food-images/\(UUID().uuidString).jpg")
                
                print("📤 Uploading to Firebase...")
                _ = try await imageRef.putDataAsync(data, metadata: nil)
                let downloadURL = try await imageRef.downloadURL()
                print("✅ Upload successful! URL: \(downloadURL.absoluteString)")
                
                // Update the imageUrl on the main thread
                await MainActor.run {
                    imageUrl = downloadURL.absoluteString
                    isUploading = false
                    print("🔄 Updated image URL in view: \(imageUrl ?? "none")")
                }
            } catch {
                print("❌ Error uploading image: \(error.localizedDescription)")
                await MainActor.run {
                    isUploading = false
                    errorMessage = "Failed to upload image: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
