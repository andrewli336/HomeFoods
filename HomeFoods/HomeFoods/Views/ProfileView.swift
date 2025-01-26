//
//  ProfileView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/25/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let currentUser = appViewModel.currentUser {
                VStack(spacing: 10) {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        )
                    
                    Text(currentUser.name)
                        .font(.title)
                        .bold()
                    Text(currentUser.email)
                        .foregroundColor(.gray)
                }
            } else {
                Text("No user data available.")
            }

            Spacer()

            Button("Edit Profile") {
                print("Navigate to edit profile screen")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    let appViewModel = AppViewModel()
    ProfileView()
        .environmentObject(appViewModel)
}
