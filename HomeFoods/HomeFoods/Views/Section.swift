//
//  Section.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/2/25.
//

import SwiftUI

struct CategorySection: View {
    let title: String
    let kitchens: [Kitchen]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Title
            SectionHeader(title: title)
            
            // Horizontal ScrollView for Kitchens in the Category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(kitchens) { kitchen in
                        NavigationLink(destination: KitchenDetailView(kitchen: kitchen)) {
                            KitchenCard(kitchen: kitchen)
                                .frame(width: 250) // Set a fixed width for the cards
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .bold()
            Spacer()
            Button("View All") {
                // Handle View All Action
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
}
