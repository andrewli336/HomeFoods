//
//  OrderRow.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct OrderRow: View {
    let orderName: String
    let status: String
    
    var body: some View {
        HStack {
            Text(orderName)
                .font(.headline)
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}
