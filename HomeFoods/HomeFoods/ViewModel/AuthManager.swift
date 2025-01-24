//
//  AuthManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/23/25.
//

import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    @Published var currentUser: User?

    init() {
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
        } catch {
            print("Failed to logout: \(error.localizedDescription)")
        }
    }
}
