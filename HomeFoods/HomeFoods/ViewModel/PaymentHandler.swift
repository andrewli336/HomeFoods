//
//  PaymentHandler.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/23/25.
//

import SwiftUI
import Stripe
import StripePaymentSheet

class PaymentHandler: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var isLoading = false
    
    // Removed paymentResult property and added onPaymentCompletion callback
    var onPaymentCompletion: ((PaymentSheetResult) -> Void)?
    
    func preparePayment(amount: Double, completion: @escaping (PaymentSheet?) -> Void) {
        isLoading = true
        
        // Convert amount to cents (Stripe uses smallest currency unit)
        let amountInCents = Int(amount * 100)
        
        // Get payment intent client secret from your backend
        TestBackend.shared.createPaymentIntent(amount: amountInCents) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let clientSecret):
                    // Create payment sheet configuration
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "HomeFoods"
                    
                    // Optional: Configure Apple Pay (if you want to test it)
                    // configuration.applePay = .init(merchantId: "merchant.com.yourcompany.homefoods", merchantCountryCode: "US")
                    
                    // Create the payment sheet
                    let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
                    self.paymentSheet = paymentSheet
                    completion(paymentSheet)
                    
                case .failure(let error):
                    print("Failed to create payment intent: \(error)")
                    completion(nil)
                }
            }
        }
    }
}
