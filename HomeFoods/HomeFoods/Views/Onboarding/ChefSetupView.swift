//
//  ChefSetupView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI
import FirebaseFirestore

struct ChefSetupView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentPage = 0
    @State private var kitchenName = ""
    @State private var kitchenDescription = ""
    @State private var kitchenCuisine = ""
    @State private var kitchenAddress = "" // ✅ Store the final address
    @State private var kitchenGeoPoint: GeoPoint? // ✅ Store converted GeoPoint
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPage) {
                    ChefIntroPage(nextPage: nextPage)
                        .tag(0)

                    AddKitchenPage(
                        kitchenName: $kitchenName,
                        kitchenDescription: $kitchenDescription,
                        kitchenCuisine: $kitchenCuisine,
                        nextPage: { address, geoPoint in
                            kitchenAddress = address // ✅ Save address
                            kitchenGeoPoint = geoPoint // ✅ Save GeoPoint
                            nextPage() // ✅ Call nextPage
                        }
                    )
                    .tag(1)

                    ChefApprovalPage(
                        kitchenName: kitchenName,
                        kitchenDescription: kitchenDescription,
                        kitchenAddress: kitchenAddress,
                        onSubmit: submitForApproval
                    )
                    .tag(2)

                    ChefTutorialPage(finishSetup: finishSetup)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                PageIndicator(currentPage: $currentPage, totalPages: 4)

                Spacer()
            }
            .padding()
        }
    }

    private func nextPage() {
        if currentPage < 3 {
            currentPage += 1
        }
    }

    private func submitForApproval() {
        guard !kitchenName.isEmpty, !kitchenDescription.isEmpty, !kitchenAddress.isEmpty else {
            showError = true
            return
        }

        // ✅ Update the user's address in their account
        if let userId = appViewModel.currentUser?.id {
            appViewModel.updateUserAddress(userId: userId, newAddress: kitchenAddress)
        }

        appViewModel.submitChefApplication(
            kitchenName: kitchenName,
            kitchenDescription: kitchenDescription,
            kitchenAddress: kitchenAddress, // ✅ Submit final address
            kitchenGeoPoint: kitchenGeoPoint // ✅ Submit GeoPoint
        ) { success in
            if success {
                nextPage()
            } else {
                showError = true
            }
        }
    }

    private func finishSetup() {
        appViewModel.showChefSetupView = false
        appViewModel.isChefMode = false
    }
}
