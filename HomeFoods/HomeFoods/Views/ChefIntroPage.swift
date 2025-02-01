//
//  ChefIntroPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//
import SwiftUI

struct ChefIntroPage: View {
    var nextPage: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Chef Mode!")
                .font(.largeTitle)
                .bold()

            Text("As a chef, you can share your homemade meals with your community. Follow the steps below to get started.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: nextPage) {
                Text("Continue")
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
