//
//  CartCheckoutView.swift
//  HomeFoods
//
//  Created by Andrew Li on 3/2/25.
//

import SwiftUI
import Stripe
import StripePaymentSheet

struct CartCheckoutView: View {
    let totalCost: Double
    @Binding var isPlacingOrder: Bool
    let placeOrder: () -> Void
    
    @EnvironmentObject var orderViewModel: OrderViewModel
    @StateObject private var paymentHandler = PaymentHandler()
    
    var body: some View {
        VStack(spacing: 16) {
            // Order Type Section
            if let order = orderViewModel.cartOrder {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: orderTypeIcon)
                            .foregroundColor(orderTypeColor)
                        Text(orderTypeTitle)
                            .font(.headline)
                            .foregroundColor(orderTypeColor)
                    }
                    .padding(.horizontal)
                    
                    if order.orderType == .preorder {
                        Text("Multiple pickup times selected")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
            }

            // Cost Breakdown
            VStack(spacing: 12) {
                Divider()
                
                HStack {
                    Text("Subtotal")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(totalCost, specifier: "%.2f")")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                HStack {
                    Text("Total")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("$\(totalCost, specifier: "%.2f")")
                        .font(.title3)
                        .bold()
                }
                .padding(.horizontal)
            }

            // Place Order Button
            Button(action: handlePaymentButtonTapped) {
                HStack {
                    if paymentHandler.isLoading || isPlacingOrder {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(buttonText)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(paymentHandler.isLoading || isPlacingOrder ? Color.gray : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(paymentHandler.isLoading || isPlacingOrder)
        }
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: -5)
    }
    
    private var buttonText: String {
        if paymentHandler.isLoading {
            return "Preparing Payment..."
        } else if isPlacingOrder {
            return "Placing Order..."
        } else {
            return "Pay & Place Order"
        }
    }
    
    private func handlePaymentButtonTapped() {
        // Configure payment completion handler
        paymentHandler.onPaymentCompletion = { result in
            handlePaymentResult(result)
        }
        
        // Prepare the payment
        paymentHandler.preparePayment(amount: totalCost) { paymentSheet in
            if let paymentSheet = paymentSheet {
                // Present the payment sheet
                DispatchQueue.main.async {
                    if let topViewController = UIViewController.topMostViewController() {
                        paymentSheet.present(from: topViewController) { result in
                            paymentHandler.onPaymentCompletion?(result)
                        }
                    } else {
                        print("ERROR: Could not find a view controller to present the payment sheet")
                    }
                }
            }
        }
    }
    
    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            // Payment was successful, place the order
            placeOrder()
        case .canceled:
            print("Payment canceled")
        case .failed(let error):
            print("Payment failed: \(error.localizedDescription)")
        }
    }
    
    private var orderTypeIcon: String {
        guard let orderType = orderViewModel.cartOrder?.orderType else { return "cart" }
        switch orderType {
        case .grabAndGo:
            return "bag.fill"
        case .preorder:
            return "clock.fill"
        case .request:
            return "bell.fill"
        }
    }
    
    private var orderTypeColor: Color {
        guard let orderType = orderViewModel.cartOrder?.orderType else { return .gray }
        switch orderType {
        case .grabAndGo:
            return .green
        case .preorder:
            return .orange
        case .request:
            return .blue
        }
    }
    
    private var orderTypeTitle: String {
        guard let orderType = orderViewModel.cartOrder?.orderType else { return "Cart" }
        switch orderType {
        case .grabAndGo:
            return "Grab & Go Order"
        case .preorder:
            return "Preorder"
        case .request:
            return "Special Request"
        }
    }
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
