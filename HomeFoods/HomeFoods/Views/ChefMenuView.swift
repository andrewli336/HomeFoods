//
//  ChefMenuView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//
import SwiftUI
import FirebaseFirestore

struct ChefMenuView: View {
    @StateObject private var viewModel = ChefMenuViewModel() // Initialize ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Kitchen")
                .font(.title)
                .bold()
            
            // Input fields
            TextField("Kitchen Name", text: $viewModel.kitchenName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Kitchen Description", text: $viewModel.kitchenDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Cuisine Type", text: $viewModel.kitchenCuisine)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Rating (e.g., 4.5)", text: $viewModel.kitchenRating)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            TextField("Latitude", text: $viewModel.latitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            TextField("Longitude", text: $viewModel.longitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(.horizontal)
            
            // Save button
            Button(action: viewModel.addKitchen) {
                if viewModel.isLoading {
                    ProgressView() // Show a spinner while loading
                } else {
                    Text("Save Kitchen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .disabled(viewModel.isLoading) // Disable button while loading
            
            // Feedback messages
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ChefMenuView()
}
