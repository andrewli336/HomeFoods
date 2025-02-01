//
//  OrderConfirmationView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/24/24.
//

import SwiftUI

struct OrderConfirmationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)

            Text("Order Placed!")
                .font(.largeTitle)
                .bold()

            Text("Thank you for your order. You’ll receive a confirmation email shortly.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                // Handle any post-confirmation actions, like returning to the home screen
            }) {
                Text("Back to Home")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Order Confirmation")
        .navigationBarTitleDisplayMode(.inline)
    }
}
