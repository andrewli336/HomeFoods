//
//  ChefOrdersView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct ChefOrdersView: View {
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Picker
                Picker("Order Type", selection: $selectedSection) {
                    Text("Preorders").tag(0)
                    Text("Requests").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selection
                switch selectedSection {
                case 0:
                    ChefPreorderView()
                case 1:
                    ChefRequestsView()
                case 2:
                    ChefCompletedView()
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Kitchen Orders")
        }
    }
}

// Placeholder view for Requests
struct ChefRequestsView: View {
    var body: some View {
        VStack {
            Image(systemName: "bell.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            Text("Requests Coming Soon")
                .font(.title2)
            Text("This feature will allow you to manage special food requests")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// Placeholder view for Completed Orders
struct ChefCompletedView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            Text("Completed Orders Coming Soon")
                .font(.title2)
            Text("This feature will show your history of completed orders")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
