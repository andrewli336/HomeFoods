//
//  ChefApprovalPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct ChefApprovalPage: View {
    let kitchenName: String
    let kitchenDescription: String
    let kitchenAddress: String
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Submit for Approval")
                .font(.largeTitle)
                .bold()

            Text("Once your kitchen is approved by admins, you can start selling your meals!")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: onSubmit) {
                Text("Submit for Approval")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
