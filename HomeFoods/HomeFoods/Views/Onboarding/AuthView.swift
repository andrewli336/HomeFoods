//
//  AuthView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/23/25.
//
import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 30) {
            // Logo and App Title
            VStack(spacing: 15) {
                Image(systemName: "house.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("HomeFoods")
                    .font(.largeTitle)
                    .bold()
                
                Text("Discover homemade meals in your community")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Sign in with Google button
            GoogleSignInButton(action: signInWithGoogle, isLoading: isLoading)
                .padding(.horizontal, 30)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Terms and Privacy text
            Text("By signing in, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        
        appViewModel.signInWithGoogle()
    }
}

struct GoogleSignInButton: View {
    var action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 8)
                } else {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                        .padding(.trailing, 8)
                }
                
                Text("Sign in with Google")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}
