//
//  CartCheckoutView.swift
//  HomeFoods
//
//  Created by Andrew Li on 3/2/25.
//

import SwiftUI
import StripePaymentSheet

struct CartCheckoutView: View {
    let totalCost: Double
    @Binding var isPlacingOrder: Bool
    @State private var showConfirmation = false
    let placeOrder: () -> Void
    @StateObject private var paymentHandler = PaymentHandler()
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple Total Display
            VStack {
                Text("Total: $\(String(format: "%.2f", totalCost))")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.top)
            
            // Additional information for testing
            #if DEBUG
            VStack(alignment: .leading, spacing: 8) {
                Text("Test Card: 4242 4242 4242 4242")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Any future date, any 3 digits for CVC, any postal code")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            #endif
            
            // Pay Button
            Button(action: handlePayment) {
                HStack {
                    if paymentHandler.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(paymentHandler.isLoading ? "Processing..." : "Pay Now $\(String(format: "%.2f", totalCost))")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(paymentHandler.isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(paymentHandler.isLoading)
            
            // Error message display
            if let errorMessage = paymentHandler.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            // Debug connection status
            #if DEBUG
            Button("Test Backend Connection") {
                testBackendConnection()
            }
            .font(.caption)
            .padding(.top)
            #endif
        }
        .padding(.vertical)
        // Show payment confirmation
        .sheet(isPresented: $showConfirmation) {
            OrderConfirmationView(showCartSheet: $isPlacingOrder)
        }
    }
    
    private func handlePayment() {
        Task {
            do {
                print("Starting payment flow...")
                let orderId = UUID().uuidString // Just a random ID for testing
                print("Generated order ID: \(orderId)")
                
                // Use the shared instance for consistency
                let sharedHandler = PaymentHandler.shared
                
                // Reset any previous payment sheet
                await MainActor.run {
                    sharedHandler.paymentSheet = nil
                    self.paymentHandler.paymentSheet = nil
                }
                
                // Prepare the payment sheet
                print("Preparing payment sheet...")
                let paymentSheet = try await paymentHandler.preparePayment(
                    amount: totalCost,
                    orderId: orderId
                )
                
                await MainActor.run {
                    print("Payment sheet created, setting in both instances...")
                    // Set the payment sheet in both the view model and shared instance
                    self.paymentHandler.paymentSheet = paymentSheet
                    sharedHandler.paymentSheet = paymentSheet
                    
                    print("Presenting payment sheet...")
                    // Present the payment sheet after a short delay to ensure UI updates
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.presentPaymentSheet { result in
                            self.handlePaymentCompletion(result: result)
                        }
                    }
                }
            } catch {
                print("❌ Payment preparation failed:", error)
                await MainActor.run {
                    paymentHandler.errorMessage = "Payment setup failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func presentPaymentSheet(completion: @escaping (PaymentSheetResult) -> Void) {
        // Get the root view controller
        guard let rootController = UIApplication.shared.windows.first?.rootViewController else {
            print("❌ No root controller found")
            completion(.failed(error: NSError(domain: "PaymentError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot present payment sheet"])))
            return
        }
        
        // Find the currently presented controller (if any)
        var presentingController = rootController
        while let presented = presentingController.presentedViewController {
            presentingController = presented
        }
        
        // Check both instances for the payment sheet
        let sharedPaymentSheet = PaymentHandler.shared.paymentSheet
        let localPaymentSheet = paymentHandler.paymentSheet
        
        print("Shared payment sheet: \(sharedPaymentSheet != nil ? "exists" : "nil")")
        print("Local payment sheet: \(localPaymentSheet != nil ? "exists" : "nil")")
        
        // Use whichever payment sheet is available
        guard let paymentSheet = sharedPaymentSheet ?? localPaymentSheet else {
            print("❌ Payment sheet not prepared in either instance")
            completion(.failed(error: NSError(domain: "PaymentError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Payment sheet not ready"])))
            return
        }
        
        // Present the payment sheet from the appropriate controller
        print("Presenting payment sheet from controller: \(type(of: presentingController))")
        DispatchQueue.main.async {
            paymentSheet.present(from: presentingController) { result in
                print("Payment result received: \(result)")
                completion(result)
            }
        }
    }
    
    private func handlePaymentCompletion(result: PaymentSheetResult) {
        paymentHandler.paymentResult = result
        
        switch result {
        case .completed:
            // Payment successful!
            print("✅ Payment completed successfully!")
            placeOrder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfirmation = true
            }
        case .failed(let error):
            print("❌ Payment failed:", error)
            paymentHandler.errorMessage = "Payment failed: \(error.localizedDescription)"
        case .canceled:
            print("Payment canceled by user")
        }
    }
    
    #if DEBUG
    private func testBackendConnection() {
        Task {
            do {
                let url = URL(string: "http://localhost:3000")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    await MainActor.run {
                        paymentHandler.errorMessage = "✅ Backend connection successful!"
                    }
                } else {
                    await MainActor.run {
                        paymentHandler.errorMessage = "⚠️ Backend responded with status: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    }
                }
            } catch {
                await MainActor.run {
                    paymentHandler.errorMessage = "❌ Backend connection failed: \(error.localizedDescription)"
                }
            }
        }
    }
    #endif
}
import UIKit

extension UIViewController {
    /// Find the topmost view controller that can present another view controller
    static func topMostViewController() -> UIViewController? {
        // Get the root view controller
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return nil
        }
        
        return findTopViewController(rootViewController)
    }
    
    private static func findTopViewController(_ controller: UIViewController) -> UIViewController {
        // Check for any presented controller
        if let presentedViewController = controller.presentedViewController {
            return findTopViewController(presentedViewController)
        }
        
        // Check for navigation controller
        if let navigationController = controller as? UINavigationController {
            if let topViewController = navigationController.topViewController {
                return findTopViewController(topViewController)
            }
            return controller
        }
        
        // Check for tab bar controller
        if let tabBarController = controller as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return findTopViewController(selectedViewController)
            }
            return controller
        }
        
        // No more view controllers to check
        return controller
    }
}

// This class handles presenting the Stripe payment sheet
class StripePaymentHostingController: UIViewController {
    private let completion: (PaymentSheetResult) -> Void
    
    init(completion: @escaping (PaymentSheetResult) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        
        // Make the controller transparent/invisible
        self.view.backgroundColor = .clear
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present the payment sheet from this controller
        if let paymentSheet = PaymentHandler.shared.paymentSheet {
            paymentSheet.present(from: self) { [weak self] result in
                // Dismiss this controller first
                self?.dismiss(animated: true) {
                    // Then call the completion handler
                    self?.completion(result)
                }
            }
        } else {
            // If for some reason we don't have a payment sheet, just dismiss
            self.dismiss(animated: true) {
                self.completion(.canceled)
            }
        }
    }
}
