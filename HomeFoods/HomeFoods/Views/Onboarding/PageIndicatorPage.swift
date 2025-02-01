//
//  PageIndicatorPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct PageIndicator: View {
    @Binding var currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(0..<totalPages), id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.green : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.top, 8)
    }
}
