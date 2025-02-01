//
//  ChefTutorialPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct ChefTutorialPage: View {
    var finishSetup: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How to Use Chef Mode")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                Text("✅ Upload food items to your menu.")
                Text("✅ Set up preorders & schedule meals.")
                Text("✅ Accept customer requests.")
                Text("✅ Manage orders and update availability.")
            }
            .padding()

            Spacer()

            Button(action: finishSetup) {
                Text("Finish Setup")
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
