//
//  AuthManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 3/2/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AuthManager: ObservableObject {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // MARK: - Google Sign In
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase Client ID not found"])))
            return
        }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "AuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token from Google Sign In"])))
                return
            }
            
            // Create Firebase credential with Google ID token
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            self.auth.signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(NSError(domain: "AuthManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to get user from Firebase"])))
                    return
                }
                
                // Check if the user is new or existing
                self.db.collection("accounts").document(firebaseUser.uid).getDocument { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    // If the document doesn't exist, create a new user profile
                    if snapshot == nil || !snapshot!.exists {
                        self.createUserProfile(for: firebaseUser, with: user.profile!.name, email: user.profile!.email) {
                            // Wait for profile creation to complete before returning success
                            completion(.success(firebaseUser))
                        }
                    } else {
                        completion(.success(firebaseUser))
                    }
                }
            }
        }
    }
    
    // MARK: - User Profile Management
    

    private func createUserProfile(for user: User, with name: String, email: String, completion: @escaping () -> Void = {}) {
        self.checkIfAdmin(email: email) { isAdmin in
            let newAccount = Account(
                id: user.uid,
                name: name,
                email: email,
                profilePictureUrl: user.photoURL?.absoluteString,
                accountCreationDate: Date(),
                isChef: false,
                wantsToBeChef: false,
                isAdmin: isAdmin,
                kitchenId: nil,
                favoriteCuisines: nil,
                howHeardAboutUs: nil,
                address: nil
            )
            
            do {
                try self.db.collection("accounts").document(user.uid).setData(from: newAccount)
                print("✅ User profile created in Firestore with isAdmin: \(isAdmin)")
                completion()
            } catch {
                print("❌ Failed to create user profile: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        // Sign out from Firebase
        try auth.signOut()
        
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - Helper Methods
    
    private func checkIfAdmin(email: String, completion: @escaping (Bool) -> Void) {
        let adminRef = db.collection("config").document("adminEmails")
        
        adminRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching admin list: \(error.localizedDescription)")
                completion(false) // Assume not an admin if there's an error
                return
            }
            
            if let data = document?.data(), let emails = data["emails"] as? [String] {
                completion(emails.contains(email))
            } else {
                completion(false) // Assume not an admin if there's no data
            }
        }
    }
}

// MARK: - SwiftUI Helper
extension View {
    func getUIViewController() -> UIViewController {
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return UIViewController()
        }
        
        // Return the most presented view controller
        var currentController = rootViewController
        while let presentedController = currentController.presentedViewController {
            currentController = presentedController
        }
        
        return currentController
    }
}
