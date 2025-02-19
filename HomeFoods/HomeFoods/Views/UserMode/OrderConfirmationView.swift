//
//  OrderConfirmationView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/24/24.
//

import SwiftUI

struct OrderConfirmationView: View {
    @Binding var showCartSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Order Confirmed!")
                .font(.title)
                .bold()
            
            Text("Thank you for your order.")
                .foregroundColor(.secondary)
            
            Button("Done") {
                showCartSheet = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}
