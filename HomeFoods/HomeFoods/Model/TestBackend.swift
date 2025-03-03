//
//  TestBackend.swift
//  HomeFoods
//
//  Created by Andrew Li on 3/2/25.
//

import Foundation

class TestBackend {
    static let shared = TestBackend()
    
    // For local testing with the provided Node.js server, use:
    private let backendURL = "http://localhost:3000"
    // For a deployed backend, use your server URL
    // private let backendURL = "https://your-production-backend.com"
    
    // IMPORTANT: Replace this with your actual publishable key from the Stripe Dashboard
    // Get this from https://dashboard.stripe.com/test/apikeys
    private let publishableKey = "pk_test_51OreplaceThisWithYourActualKey"
    
    // Function to create a payment intent on your server
    func createPaymentIntent(amount: Int, completion: @escaping (Result<String, Error>) -> Void) {
        // For quick testing, you can simulate a server response
        // IMPORTANT: This is only for testing! In production, always create payment intents on your server
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Simulated successful response with a dummy client secret
            // In a real app, this would come from your backend after calling Stripe's API
            let dummyClientSecret = "pi_1234_secret_5678"
            completion(.success(dummyClientSecret))
            
            // Uncomment to simulate an error
            // completion(.failure(NSError(domain: "TestBackend", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to create payment intent"])))
        }
    }
    
    // Get your Stripe publishable key
    func getPublishableKey() -> String {
        return publishableKey
    }
}
