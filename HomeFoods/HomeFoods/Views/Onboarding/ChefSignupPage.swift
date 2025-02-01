//
//  ChefSignupPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct ChefSignupPage: View {
    @Binding var wantsToBeChef: Bool
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Would you like to sign up as a chef?")
                .font(.headline)
                .padding()

            Toggle("Yes, I want to be a chef", isOn: $wantsToBeChef)
                .padding()

            Spacer()

            Button(action: onSave) {
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
    }
}
