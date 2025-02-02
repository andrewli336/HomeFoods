//
//  OrderRowView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/2/25.
//

import SwiftUI

struct OrderRowView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(order.kitchenName)
                .font(.headline)
            Text("Placed on \(formattedDate(order.datePlaced))")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text("Total: $\(order.totalCost, specifier: "%.2f")")
                    .bold()
                Spacer()
                Text(order.datePickedUp == nil ? "In Progress" : "Completed")
                    .font(.caption)
                    .foregroundColor(order.datePickedUp == nil ? .orange : .green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(order.datePickedUp == nil ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                    .cornerRadius(5)
            }
        }
        .padding(.vertical, 5)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
