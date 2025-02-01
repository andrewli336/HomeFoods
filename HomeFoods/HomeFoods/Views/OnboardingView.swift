//
//  OnboardingView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/25/25.
//

import SwiftUI
import FirebaseFirestore

struct OnboardingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedCuisines: [String] = [] // Favorite cuisines
    @State private var selectedHowHeard: String? = nil // How the user heard about the app
    @State private var wantsToBeChef: Bool = false
    @State private var currentPage = 0 // Track the current page
    @State private var errorMessage: String? = nil // Display error message

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPage) {
                    FavoriteCuisinesPage(selectedCuisines: $selectedCuisines, nextPage: nextPage)
                        .tag(0)

                    HowHeardPage(selectedHowHeard: $selectedHowHeard, nextPage: nextPage)
                        .tag(1)

                    ChefSignupPage(wantsToBeChef: $wantsToBeChef, onSave: completeOnboarding)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding()

                PageIndicator(currentPage: $currentPage, totalPages: 3)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .background(Rectangle().fill(Color.gray.opacity(0.1)).edgesIgnoringSafeArea(.all))
        }
    }

    private func nextPage() {
        if currentPage < 2 {
            currentPage += 1
        }
    }

    private func completeOnboarding() {
        appViewModel.saveOnboardingData(
            favoriteCuisines: selectedCuisines,
            howHeardAboutUs: selectedHowHeard,
            wantsToBeChef: wantsToBeChef
        ) { result in
            switch result {
            case .success:
                appViewModel.completeOnboarding()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
