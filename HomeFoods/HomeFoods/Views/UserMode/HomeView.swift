//
//  HomeView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Discover Kitchens")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(appViewModel.kitchens) { kitchen in
                            NavigationLink(destination: KitchenDetailView(kitchen: kitchen)) {
                                KitchenCard(kitchen: kitchen)
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                appViewModel.fetchKitchens() // ✅ Fetch all kitchens
            }
            .navigationTitle("Home")
        }
    }
}


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
