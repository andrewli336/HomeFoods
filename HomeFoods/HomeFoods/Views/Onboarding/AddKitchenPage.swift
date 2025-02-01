//
//  AddKitchenPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct AddKitchenPage: View {
    @Binding var kitchenName: String
    @Binding var kitchenDescription: String
    var nextPage: (_ address: String) -> Void // ✅ Fix: Takes address argument

    @StateObject private var locationManager = LocationManager()
    @State private var showAddressSelection = false
    @State private var selectedManualAddress: String? // ✅ Stores manually entered address

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Up Your Kitchen")
                .font(.largeTitle)
                .bold()

            TextField("Kitchen Name", text: $kitchenName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Kitchen Description", text: $kitchenDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // 📌 Address Display Logic
            VStack(alignment: .leading, spacing: 5) {
                Text("Kitchen Address:")
                    .font(.headline)

                let finalAddress = selectedManualAddress ?? locationManager.address ?? "No address"

                Text(finalAddress)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
            }
            .padding(.horizontal)

            Divider()

            // 📌 Manual Address Entry Button
            Button("Enter Address Manually") {
                showAddressSelection = true
            }
            .foregroundColor(.blue)
            .padding()

            Button("Next") {
                let finalAddress = selectedManualAddress ?? locationManager.address ?? "No address"
                nextPage(finalAddress) // ✅ Pass final address to nextPage
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showAddressSelection) {
            AddressSelectionView(selectedAddress: $selectedManualAddress)
                .environmentObject(AppViewModel())
        }
    }
}
