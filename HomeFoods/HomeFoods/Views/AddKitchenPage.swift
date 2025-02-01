//
//  AddKitchenPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct AddKitchenPage: View {
    @Binding var kitchenName: String
    @Binding var kitchenDescription: String
    var nextPage: () -> Void
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Kitchen")
                .font(.largeTitle)
                .bold()

            TextField("Kitchen Name", text: $kitchenName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Describe your kitchen...", text: $kitchenDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Spacer()

            if showError {
                Text("Please enter a kitchen name and description.")
                    .foregroundColor(.red)
            }

            Button(action: {
                if kitchenName.isEmpty || kitchenDescription.isEmpty {
                    showError = true
                } else {
                    showError = false
                    nextPage()
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
