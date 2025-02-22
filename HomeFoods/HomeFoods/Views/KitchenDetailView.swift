//
//  KitchenDetailView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import MapKit

struct KitchenDetailView: View {
    let kitchen: Kitchen
    
    @State private var selectedTab: OrderType = .grabAndGo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                KitchenImageView(kitchen: kitchen)

                VStack(alignment: .leading, spacing: 15) {
                    KitchenTopPart(kitchen: kitchen)

                    Divider()

                    if kitchen.foodItems.contains(where: { $0.isFeatured }) {
                        FeaturedItemsView(foodItems: kitchen.foodItems)
                    }

                    Divider()

                    OrderTabsView(selectedTab: $selectedTab, kitchen: kitchen)
                }
                .padding()
            }
        }
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        .navigationTitle(kitchen.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KitchenImageView: View {
    let kitchen: Kitchen

    var body: some View {
        AsyncImage(url: URL(string: kitchen.imageUrl ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            } else if phase.error != nil {
                // Placeholder for error
                Color.red
                    .frame(height: 250)
                    .clipped()
                    .overlay(Text("Error").foregroundColor(.white))
            } else {
                // Placeholder while loading
                ProgressView()
                    .frame(height: 250)
                    .clipped()
            }
        }
    }
}

struct KitchenTopPart: View {
    let kitchen: Kitchen
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State private var owner: Account?
    @State private var isLoading = true
    @State private var distanceText: String = "Calculating..."
    @State private var showMapSheet = false // Add state for map sheet

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
                .padding(.top, 5)
            
            // Make address clickable
            Button(action: { showMapSheet = true }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text(kitchen.address ?? "Address unavailable")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.blue)
                Text(distanceText)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .bold()
            }

            Divider()

            if isLoading {
                ProgressView()
                    .padding()
            } else if let owner = owner {
                NavigationLink(destination: AccountView(account: owner)) {
                    HStack {
                        AsyncImage(url: URL(string: owner.profilePictureUrl ?? "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 50, height: 50)

                        VStack(alignment: .leading) {
                            Text(owner.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(owner.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                }
            } else {
                Text("❌ Failed to load owner details.")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Kitchen Details")
        .onAppear {
            fetchOwnerAccount()
            calculateDistance()
        }
        .sheet(isPresented: $showMapSheet) {
            KitchenMapSheet(kitchen: kitchen, isPresented: $showMapSheet)
        }
    }
    
    private func calculateDistance() {
        guard let userLocation = locationManager.userLocation else {
            distanceText = "Location unavailable"
            return
        }
        
        let kitchenLocation = CLLocation(latitude: kitchen.location.latitude, longitude: kitchen.location.longitude)
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        let distanceInMeters = userCLLocation.distance(from: kitchenLocation)
        let distanceInMiles = distanceInMeters / 1609.34

        DispatchQueue.main.async {
            distanceText = String(format: "%.1f miles away", distanceInMiles)
        }
    }

    private func fetchOwnerAccount() {
        guard !kitchen.ownerId.isEmpty else {
            print("❌ Error: Owner ID is empty")
            return
        }

        appViewModel.fetchAccount(ownerId: kitchen.ownerId) { account in
            DispatchQueue.main.async {
                self.owner = account
                self.isLoading = false
            }
        }
    }
}


struct FeaturedItemsView: View {
    let foodItems: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Featured Items")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.leading, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -20) {
                    ForEach(foodItems.filter { $0.isFeatured }) { foodItem in
                        FoodItemSquare(foodItem: foodItem)
                            .frame(width: 200)
                    }
                }
                .padding(.horizontal, -10)
            }
        }
    }
}

struct OrderTabsView: View {
    @Binding var selectedTab: OrderType
    let kitchen: Kitchen

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                OrderTypeButton(title: "Grab & Go", isSelected: selectedTab == .grabAndGo) {
                    selectedTab = .grabAndGo
                }
                OrderTypeButton(title: "Preorder", isSelected: selectedTab == .preorder) {
                    selectedTab = .preorder
                }
                OrderTypeButton(title: "Request", isSelected: selectedTab == .request) {
                    selectedTab = .request
                }
            }
            .padding(.vertical, 5)

            if selectedTab == .grabAndGo {
                GrabAndGoView(foodItems: kitchen.foodItems.filter { $0.numAvailable > 0 })
            } else if selectedTab == .preorder {
                PreorderView(kitchen: kitchen)
            } else if selectedTab == .request {
                RequestView(foodItems: kitchen.foodItems)
            }
        }
    }
}
