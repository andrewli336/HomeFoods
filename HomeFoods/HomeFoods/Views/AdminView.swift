//
//  AdminView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/2/25.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

struct AdminView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var locationManager: LocationManager // ✅ Get admin's location
    @State private var pendingKitchens: [Kitchen] = [] // ✅ Store pending kitchens
    @State private var chefNames: [String: String] = [:]
    @State private var distances: [String: String] = [:] // ✅ Store distances per kitchen
    @State private var selectedKitchen: Kitchen? // ✅ Track selected kitchen for approval
    @State private var showApprovalAlert = false // ✅ Show approval confirmation

    var body: some View {
        NavigationView {
            VStack {
                if pendingKitchens.isEmpty {
                    Text("No pending kitchens.")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(pendingKitchens, id: \.id) { kitchen in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(kitchen.name)
                                            .font(.headline)
                                        Text("Owner: \(chefNames[kitchen.ownerId] ?? "Loading...")") // ✅ Fetch dynamically
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(kitchen.address ?? "Address unavailable")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        if let distance = distances[kitchen.id ?? ""] {
                                            Text(distance) // ✅ Show distance
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        selectedKitchen = kitchen
                                        showApprovalAlert = true // ✅ Show alert before approving
                                    }) {
                                        Text("Approve")
                                            .padding(10)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Pending Kitchens")
            .onAppear {
                fetchPendingKitchens()
            }
            .alert(isPresented: $showApprovalAlert) {
                Alert(
                    title: Text("Approve Kitchen?"),
                    message: Text("Are you sure you want to approve \(selectedKitchen?.name ?? "this kitchen")?"),
                    primaryButton: .destructive(Text("Approve")) {
                        if let kitchenId = selectedKitchen?.id {
                            approveKitchen(kitchenId: kitchenId)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    /// **📌 Fetch pending kitchens**
    private func fetchPendingKitchens() {
        appViewModel.fetchPendingKitchens { kitchens in
            self.pendingKitchens = kitchens
            calculateDistances()
            fetchChefNames()
        }
    }

    /// **📌 Approve a kitchen**
    private func approveKitchen(kitchenId: String) {
        appViewModel.approveKitchen(kitchenId: kitchenId) { success in
            if success {
                pendingKitchens.removeAll { $0.id == kitchenId }
            }
        }
    }

    /// **📌 Calculate distances from admin's location**
    private func calculateDistances() {
        guard let userLocation = locationManager.userLocation else { return }

        for kitchen in pendingKitchens {
            let kitchenLocation = CLLocation(latitude: kitchen.location.latitude, longitude: kitchen.location.longitude)
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

            let distanceInMeters = userCLLocation.distance(from: kitchenLocation)
            let distanceInMiles = distanceInMeters / 1609.34 // Convert to miles

            DispatchQueue.main.async {
                self.distances[kitchen.id ?? ""] = String(format: "%.1f miles away", distanceInMiles)
            }
        }
    }

    /// **📌 Fetch chef names using `appViewModel.fetchAccount`**
    private func fetchChefNames() {
        for kitchen in pendingKitchens {
            appViewModel.fetchAccount(ownerId: kitchen.ownerId) { account in
                if let account = account {
                    DispatchQueue.main.async {
                        self.chefNames[kitchen.ownerId] = account.name
                    }
                } else {
                    DispatchQueue.main.async {
                        self.chefNames[kitchen.ownerId] = "Unknown Chef"
                    }
                }
            }
        }
    }
}
