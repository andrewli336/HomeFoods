//
//  PaymentHandler.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/23/25.
//

import SwiftUI
import StripePaymentSheet

class PaymentHandler: ObservableObject {
    // Singleton instance for accessing from UIKit components
    static let shared = PaymentHandler()
    // Published properties that the UI can observe
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var paymentResult: PaymentSheetResult?
    
    // For holding the payment sheet
    var paymentSheet: PaymentSheet?
    
    // Backend URL - change this if your server runs on a different port
    private let backendURL = "https://us-central1-your-project-id.cloudfunctions.net/api"
    
    // Prepares a payment by getting a paymentIntent from the backend
    func preparePayment(amount: Double, orderId: String) async throws -> PaymentSheet {
        // Clear any previous errors
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        
        do {
            // 1. Request payment intent from our backend
            let paymentIntentResponse = try await fetchPaymentIntent(amount: amount, orderId: orderId)
            
            // 2. Configure the payment sheet
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Your Store Name"
            configuration.applePay = .init(merchantId: "merchant.com.yourdomain.app", merchantCountryCode: "US") // Replace with your merchant ID
            configuration.allowsDelayedPaymentMethods = true
            
            // 3. Create and return the payment sheet
            let paymentSheet = PaymentSheet(
                paymentIntentClientSecret: paymentIntentResponse.clientSecret,
                configuration: configuration
            )
            
            // 4. Update UI state
            await MainActor.run {
                self.isLoading = false
            }
            
            return paymentSheet
            
        } catch {
            // Handle errors
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to prepare payment: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // Fetches a payment intent from our backend server
    private func fetchPaymentIntent(amount: Double, orderId: String) async throws -> PaymentIntentResponse {
        // 1. Create the URL for our backend endpoint
        guard let url = URL(string: "\(backendURL)/create-payment-intent") else {
            throw URLError(.badURL)
        }
        
        // 2. Prepare the request body
        let body: [String: Any] = [
            "amount": amount,
            "currency": "usd",
            "orderId": orderId
        ]
        
        // 3. Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // 4. Make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Validate the response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "PaymentError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // 6. Parse the response
        let paymentIntentResponse = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
        
        // 7. Set the publishable key in the Stripe SDK
        StripeAPI.defaultPublishableKey = paymentIntentResponse.publishableKey
        
        return paymentIntentResponse
    }
}

// Response model for our backend API
struct PaymentIntentResponse: Decodable {
    let clientSecret: String
    let publishableKey: String
}
