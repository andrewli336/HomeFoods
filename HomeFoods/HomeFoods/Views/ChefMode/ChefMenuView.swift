//
//  ChefMenuView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import MapKit

import SwiftUI

struct ChefMenuView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var kitchen: Kitchen?
    @State private var isLoading = true
    @State private var isShowingFoodItemSheet = false
    @State private var selectedFoodItem: FoodItem? = nil
    @State private var showMapSheet = false
    
    // Edit states
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    @State private var editedCuisine: String = ""
    @State private var editedAddress: String? = nil
    @State private var editedImageUrl: String? = nil
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var isUploading = false
    @State private var showAddressSelection = false
    @State private var geoPoint: GeoPoint? = nil
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapAnnotation: MapAnnotationPoint? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let kitchen = kitchen {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Kitchen Image Section
                            if isEditing {
                                PhotosPicker(selection: $selectedImage, matching: .images) {
                                    VStack {
                                        if isUploading {
                                            ProgressView()
                                                .frame(height: 250)
                                        } else if let imageUrl = editedImageUrl, !imageUrl.isEmpty {
                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 250)
                                                    .clipped()
                                            } placeholder: {
                                                ProgressView()
                                                    .frame(height: 250)
                                            }
                                        } else {
                                            ZStack {
                                                Color.gray.opacity(0.2)
                                                Label("Select Image", systemImage: "photo.fill")
                                            }
                                            .frame(height: 250)
                                        }
                                    }
                                }
                                .onChange(of: selectedImage) { newValue in
                                    if let newValue {
                                        uploadImage(item: newValue)
                                    }
                                }
                            } else {
                                KitchenImageView(kitchen: kitchen)
                            }
                            
                            // Kitchen Details Section
                            if isEditing {
                                KitchenEditForm(
                                    editedName: $editedName,
                                    editedDescription: $editedDescription,
                                    editedCuisine: $editedCuisine,
                                    editedAddress: $editedAddress,
                                    showAddressSelection: $showAddressSelection,
                                    mapAnnotation: $mapAnnotation,
                                    region: $region
                                )
                                
                                Button(action: saveKitchenDetails) {
                                    Text("Save Changes")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            } else {
                                KitchenDetailsView(
                                    kitchen: kitchen,
                                    showMapSheet: $showMapSheet
                                )
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Menu Management Section
                            MenuManagementSection(
                                kitchen: kitchen,
                                onAddItem: {
                                    selectedFoodItem = nil
                                    isShowingFoodItemSheet = true
                                },
                                onEditItem: { item in
                                    selectedFoodItem = item
                                    isShowingFoodItemSheet = true
                                },
                                onDeleteItem: { itemId in
                                    deleteFoodItem(itemId: itemId)
                                }
                            )
                        }
                    }
                } else {
                    Text("❌ Failed to load kitchen data")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Manage Menu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(isEditing ? "Cancel" : "Edit") {
                if isEditing {
                    resetEditedValues()
                }
                isEditing.toggle()
            })
            .onAppear {
                fetchChefKitchen()
            }
            .sheet(isPresented: $isShowingFoodItemSheet) {
                if let kitchen = kitchen {
                    EditFoodItemView(kitchen: kitchen, foodItem: selectedFoodItem) {
                        fetchChefKitchen()
                    }
                }
            }
            .sheet(isPresented: $showAddressSelection) {
                AddressSelectionView(selectedAddress: $editedAddress, showAddressSelection: $showAddressSelection)
                    .onChange(of: editedAddress) { newAddress in
                        if let address = newAddress {
                            updateLocationFromAddress(address)
                        }
                    }
            }
            .sheet(isPresented: $showMapSheet) {
                if let kitchen = kitchen {
                    KitchenMapSheet(kitchen: kitchen, isPresented: $showMapSheet)
                }
            }
        }
    }
    
    private func uploadImage(item: PhotosPickerItem) {
        isUploading = true
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw URLError(.badServerResponse)
                }
                
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("kitchen-images/\(UUID().uuidString).jpg")
                
                _ = try await imageRef.putDataAsync(data, metadata: nil)
                let downloadURL = try await imageRef.downloadURL()
                
                await MainActor.run {
                    editedImageUrl = downloadURL.absoluteString
                    isUploading = false
                }
            } catch {
                print("❌ Error uploading image: \(error.localizedDescription)")
                await MainActor.run {
                    isUploading = false
                }
            }
        }
    }
    
    private func updateLocationFromAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    let coordinate = location.coordinate
                    self.geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self.region = MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    self.mapAnnotation = MapAnnotationPoint(coordinate: coordinate)
                }
            }
        }
    }
    
    private func resetEditedValues() {
        if let kitchen = kitchen {
            editedName = kitchen.name
            editedDescription = kitchen.description
            editedCuisine = kitchen.cuisine
            editedAddress = kitchen.address
            editedImageUrl = kitchen.imageUrl
            
            let location = kitchen.location
            geoPoint = location
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapAnnotation = MapAnnotationPoint(coordinate: coordinate)
        }
    }
    
    private func saveKitchenDetails() {
        guard let kitchen = kitchen,
              let kitchenId = kitchen.id,
              let location = geoPoint else { return }
        
        appViewModel.updateKitchenDetails(
            kitchenId: kitchenId,
            name: editedName,
            description: editedDescription,
            cuisine: editedCuisine,
            address: editedAddress ?? "",
            imageUrl: editedImageUrl,
            location: location
        ) {
            fetchChefKitchen()
            isEditing = false
        }
    }
    
    private func fetchChefKitchen() {
        guard let kitchenId = appViewModel.currentUser?.kitchenId else {
            print("❌ No kitchen ID found")
            isLoading = false
            return
        }
        
        appViewModel.fetchKitchenById(kitchenId: kitchenId) { fetchedKitchen in
            DispatchQueue.main.async {
                self.kitchen = fetchedKitchen
                self.isLoading = false
                if !isEditing {
                    resetEditedValues()
                }
            }
        }
    }
    
    private func deleteFoodItem(itemId: String) {
        guard let kitchenId = kitchen?.id else { return }
        
        appViewModel.deleteFoodItem(kitchenId: kitchenId, foodItemId: itemId) {
            fetchChefKitchen()
        }
    }
}

struct KitchenDetailsView: View {
    let kitchen: Kitchen
    @Binding var showMapSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(kitchen.name)
                .font(.title2)
                .bold()
                .lineLimit(2)
            
            Text("\(kitchen.cuisine) • \(kitchen.rating, specifier: "%.1f") ⭐")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(kitchen.description)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
            
            Button(action: { showMapSheet = true }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text(kitchen.address ?? "Address unavailable")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}
