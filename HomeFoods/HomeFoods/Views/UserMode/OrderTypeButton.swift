//
//  OrderTypeButton.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct OrderTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.green : Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}
