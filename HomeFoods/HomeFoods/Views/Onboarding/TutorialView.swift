//
//  TutorialView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/25/25.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
        VStack(spacing: 20) {
            Text("Get Started with HomeFoods!")
                .font(.largeTitle)
                .bold()

            Text("Here are some tips to get the most out of your experience:")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            // Example of tutorial content
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Browse kitchens nearby.")
                Text("2. Place orders easily.")
                Text("3. Switch to chef mode if you want to manage your own kitchen.")
            }
            .padding()

            Spacer()

            Button(action: {
                appViewModel.completeTutorial()
            }) {
                Text("Start Exploring")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
