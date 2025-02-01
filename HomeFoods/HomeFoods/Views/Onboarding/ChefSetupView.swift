//
//  ChefSetupView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct ChefSetupView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentPage = 0
    @State private var kitchenName = ""
    @State private var kitchenDescription = ""
    @State private var kitchenAddress = "" // ✅ Store the final address
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
                        nextPage: { address in
                            kitchenAddress = address // ✅ Save address
                            nextPage() // ✅ Call nextPage without arguments
                        }
                    )
                    .tag(1)

                    ChefApprovalPage(
                        kitchenName: kitchenName,
                        kitchenDescription: kitchenDescription,
                        kitchenAddress: kitchenAddress, // ✅ Pass address
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
        appViewModel.submitChefApplication(
            kitchenName: kitchenName,
            kitchenDescription: kitchenDescription,
            kitchenAddress: kitchenAddress // ✅ Submit final address
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
        appViewModel.isChefMode = true
    }
}
