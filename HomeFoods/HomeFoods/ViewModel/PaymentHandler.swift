//
//  PaymentHandler.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/23/25.
//

import Stripe
import StripePaymentSheet

class PaymentHandler: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    @Published var isLoading = false
    
    private let backendURL = "YOUR_BACKEND_URL" // Your payment backend URL
    
    func preparePayment(amount: Double, orderId: String) async throws -> PaymentSheet {
        isLoading = true
        defer { isLoading = false }
        
        // Calculate the platform fee (10%)
        let platformFeeAmount = Int((amount * 0.10) * 100) // Convert to cents
        let totalAmount = Int(amount * 100) // Convert to cents
        
        // Create payment intent
        let payload: [String: Any] = [
            "amount": totalAmount,
            "currency": "usd",
            "orderId": orderId,
            "application_fee_amount": platformFeeAmount
        ]
        
        // Make API call to your backend
        guard let url = URL(string: "\(backendURL)/create-payment-intent") else {
            throw PaymentError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let intent = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
        
        // Create PaymentSheet
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Your App Name"
        configuration.applePay = .init(
            merchantId: "YOUR_MERCHANT_ID",
            merchantCountryCode: "US"
        )
        
        return PaymentSheet(paymentIntentClientSecret: intent.clientSecret, configuration: configuration)
    }
}

// 2. Create necessary models
struct PaymentIntentResponse: Codable {
    let clientSecret: String
}

enum PaymentError: Error {
    case invalidURL
    case paymentFailed
}

// 3. Modify your CartCheckoutView to include payment
struct CartCheckoutView: View {
    let totalCost: Double
    @Binding var isPlacingOrder: Bool
    let placeOrder: () -> Void
    @EnvironmentObject var orderViewModel: OrderViewModel
    @StateObject private var paymentHandler = PaymentHandler()
    @State private var showPaymentSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Your existing cost breakdown code...
            
            // Modified Place Order Button
            Button(action: handlePayment) {
                HStack {
                    if paymentHandler.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(paymentHandler.isLoading ? "Processing..." : "Pay & Place Order")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(paymentHandler.isLoading ? Color.gray : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(paymentHandler.isLoading)
        }
        .sheet(isPresented: $showPaymentSheet) {
            if let paymentSheet = paymentHandler.paymentSheet {
                PaymentSheet.PaymentController(paymentSheet: paymentSheet, onCompletion: handlePaymentCompletion)
            }
        }
    }
    
    private func handlePayment() {
        Task {
            do {
                let orderId = UUID().uuidString // Or get from your order
                let paymentSheet = try await paymentHandler.preparePayment(
                    amount: totalCost,
                    orderId: orderId
                )
                await MainActor.run {
                    paymentHandler.paymentSheet = paymentSheet
                    showPaymentSheet = true
                }
            } catch {
                print("❌ Payment preparation failed:", error)
            }
        }
    }
    
    private func handlePaymentCompletion(result: PaymentSheetResult) {
        paymentHandler.paymentResult = result
        
        switch result {
        case .completed:
            // Payment successful, place the order
            placeOrder()
        case .failed(let error):
            print("❌ Payment failed:", error)
        case .canceled:
            print("Payment canceled")
        }
    }
}
