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
    @State private var isTutorialActive: Bool = false // Navigate to tutorial
    @State private var errorMessage: String? = nil // Display error message

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Favorite Cuisines
                VStack(spacing: 20) {
                    Text("What are your favorite cuisines?")
                        .font(.headline)
                        .padding()
                    
                    ScrollView {
                        ForEach(availableCuisines, id: \.self) { cuisine in
                            HStack {
                                Text(cuisine)
                                    .font(.body)
                                Spacer()
                                Image(systemName: selectedCuisines.contains(cuisine) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedCuisines.contains(cuisine) ? .green : .gray)
                                    .onTapGesture {
                                        if selectedCuisines.contains(cuisine) {
                                            selectedCuisines.removeAll { $0 == cuisine }
                                        } else {
                                            selectedCuisines.append(cuisine)
                                        }
                                    }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        }
                    }
                    .padding()
                }
                .tag(0)
                
                // Page 2: How Heard About Us
                VStack(spacing: 20) {
                    Text("How did you hear about us?")
                        .font(.headline)
                        .padding()
                    
                    ForEach(howHeardOptions, id: \.self) { option in
                        HStack {
                            Text(option)
                                .font(.body)
                            Spacer()
                            Image(systemName: selectedHowHeard == option ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedHowHeard == option ? .green : .gray)
                                .onTapGesture {
                                    selectedHowHeard = option
                                }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    }
                }
                .tag(1)
                
                // Page 3: Would You Like to Be a Chef?
                VStack(spacing: 20) {
                    Text("Would you like to sign up as a chef?")
                        .font(.headline)
                        .padding()
                    
                    Toggle("Yes, I want to be a chef", isOn: $wantsToBeChef)
                        .padding()
                    
                    Spacer()
                    Button(action: {
                        appViewModel.saveOnboardingData(
                            favoriteCuisines: selectedCuisines,
                            howHeardAboutUs: selectedHowHeard,
                            wantsToBeChef: wantsToBeChef
                        ) { result in
                            if case .success = result {
                                appViewModel.completeOnboarding()
                            } else if case let .failure(error) = result {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Finish Onboarding")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .padding()
            .background(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .edgesIgnoringSafeArea(.all)
            )
            
            // Progress Indicator (3 Circles)
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(currentPage == index ? Color.green : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 8)
            
            Spacer()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}
