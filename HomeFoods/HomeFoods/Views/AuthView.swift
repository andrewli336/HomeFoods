//
//  AuthView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/23/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
struct AuthView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignupMode = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(isSignupMode ? "Sign Up" : "Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isSignupMode {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                if isSignupMode {
                    appViewModel.signUp(email: email, password: password, name: name) { result in
                        if case let .failure(error) = result {
                            errorMessage = error.localizedDescription
                        }
                    }
                } else {
                    appViewModel.login(email: email, password: password) { result in
                        if case let .failure(error) = result {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }) {
                Text(isSignupMode ? "Sign Up" : "Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Button(action: {
                isSignupMode.toggle()
            }) {
                Text(isSignupMode ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    let appViewModel = AppViewModel() // Create an instance of AppViewModel
    AuthView()
        .environmentObject(appViewModel) // Provide the environment object
}
