//
//  AccountView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/2/25.
//

import SwiftUI

struct AccountView: View {
    let account: Account
    @EnvironmentObject var appViewModel: AppViewModel // ✅ Access current user/admin privileges

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ✅ Profile Image
                AsyncImage(url: URL(string: account.profilePictureUrl ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }

                // ✅ Name & Email
                Text(account.name)
                    .font(.title)
                    .bold()

                Text(account.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Divider()

                // ✅ Favorite Cuisines (if available)
                if let favoriteCuisines = account.favoriteCuisines, !favoriteCuisines.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Favorite Cuisines")
                            .font(.headline)

                        Text(favoriteCuisines.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                    }
                    .padding(.horizontal)
                }

                Divider()

                // ✅ Admin Controls (Only visible if currentUser is an admin)
                if let currentUser = appViewModel.currentUser, currentUser.isAdmin {
                    AdminActionsView(user: account)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ✅ Admin Actions (If current user is an admin)
struct AdminActionsView: View {
    let user: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Admin Actions")
                .font(.headline)
                .foregroundColor(.red)

            Button(action: {
                print("❌ Banning user \(user.name)...")
                // 🔹 Add ban user functionality
            }) {
                Text("Ban User")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                print("✅ Granting admin to \(user.name)...")
                // 🔹 Add grant admin functionality
            }) {
                Text("Grant Admin Access")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    }
}
