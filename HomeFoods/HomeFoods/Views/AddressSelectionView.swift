//
//  AddressSelectionView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//
import SwiftUI
import MapKit
import FirebaseFirestore

struct AddressSelectionView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @ObservedObject var locationManager = LocationManager()
    @StateObject private var autocompleteManager = AutocompleteManager()

    @Binding var selectedAddress: String? // ✅ Now takes a binding to pass back data
    @State private var showSaveConfirmation = false
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 10) {
            // 📌 Display saved address
            VStack(alignment: .leading, spacing: 5) {
                Text("Saved Address:")
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(selectedAddress ?? appViewModel.currentUser?.address ?? locationManager.address ?? "No address saved")
                    .font(.body)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                    .padding(.horizontal)
            }
            .padding(.top)

            Divider()

            // 📌 Search Bar for Address
            TextField("Enter or Search Address", text: $autocompleteManager.searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 📌 Address Suggestions
            List(autocompleteManager.searchResults, id: \.combinedID) { result in
                Button(action: {
                    selectAddress(result.title)
                }) {
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.headline)
                        Text(result.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(PlainListStyle())

            // 📌 Save Address Button
            Button(action: saveAddress) {
                HStack {
                    if isSaving {
                        ProgressView()
                    }
                    Text("Save Address")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedAddress != nil ? Color.blue : Color.gray)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(selectedAddress == nil || isSaving)

            Spacer()
        }
        .alert(isPresented: $showSaveConfirmation) {
            Alert(title: Text("Address Saved"),
                  message: Text("Your address has been updated successfully."),
                  dismissButton: .default(Text("OK")))
        }
        .padding()
    }

    /// Selects an address from autocomplete results
    private func selectAddress(_ address: String) {
        selectedAddress = address // ✅ Now updates the binding
        autocompleteManager.searchQuery = address
    }

    /// Saves the selected address and updates Firestore
    private func saveAddress() {
        guard let address = selectedAddress, let userId = appViewModel.currentUser?.id else { return }
        
        isSaving = true

        let db = Firestore.firestore()
        db.collection("accounts").document(userId).updateData(["address": address]) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    print("❌ Failed to save address: \(error.localizedDescription)")
                } else {
                    locationManager.address = address
                    appViewModel.currentUser?.address = address
                    showSaveConfirmation = true
                }
            }
        }
    }
}

extension MKLocalSearchCompletion {
    var combinedID: String {
        return "\(title) \(subtitle)"
    }
}
