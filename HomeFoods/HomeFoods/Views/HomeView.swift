//
//  HomeView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cartManager: CartManager // Access CartManager for cart state

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrolling content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Chinese Category
                    CategorySection(
                        title: "Chinese Cuisine",
                        kitchens: sampleKitchens.filter { $0.cuisine == "Chinese" }
                    )

                    // Vegan Category
                    CategorySection(
                        title: "Vegan Delights",
                        kitchens: sampleKitchens.filter { $0.cuisine == "Vegan" }
                    )

                    // Desserts Category
                    CategorySection(
                        title: "Sweet Treats",
                        kitchens: sampleKitchens.filter { $0.cuisine == "Desserts" }
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
        }
    }
}

struct CategorySection: View {
    @EnvironmentObject var cartManager: CartManager // Access CartManager for cart state
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
