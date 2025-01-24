//
//  KitchenDetailView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import MapKit

struct KitchenDetailView: View {
    let kitchen: Kitchen
    @EnvironmentObject var cartManager: CartManager
    
    @State private var selectedTab: OrderType = .grabAndGo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                KitchenImageView(kitchen: kitchen)

                VStack(alignment: .leading, spacing: 15) {
                    KitchenDetailsView(kitchen: kitchen)

                    Divider()

                    if kitchen.foodItems.contains(where: { $0.isFeatured }) {
                        FeaturedItemsView(foodItems: kitchen.foodItems)
                    }

                    Divider()

                    OrderTabsView(selectedTab: $selectedTab, kitchen: kitchen)
                }
                .padding()
            }
        }
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
        .navigationTitle(kitchen.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KitchenImageView: View {
    let kitchen: Kitchen

    var body: some View {
        AsyncImage(url: URL(string: kitchen.imageUrl ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            } else if phase.error != nil {
                Color.red
                    .frame(height: 250)
                    .overlay(Text("Image not found").foregroundColor(.white))
            } else {
                ProgressView()
                    .frame(height: 250)
            }
        }
    }
}

struct KitchenDetailsView: View {
    let kitchen: Kitchen

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(kitchen.name)
                .font(.title2)
                .bold()
                .lineLimit(2)

            Text("\(kitchen.cuisine) • \(kitchen.rating, specifier: "%.1f") ⭐")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(kitchen.description)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 5)
        }
    }
}

struct FeaturedItemsView: View {
    let foodItems: [FoodItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Featured Items")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.leading, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -20) {
                    ForEach(foodItems.filter { $0.isFeatured }) { foodItem in
                        FoodItemSquare(foodItem: foodItem)
                            .frame(width: 200)
                    }
                }
                .padding(.horizontal, -10)
            }
        }
    }
}

struct OrderTabsView: View {
    @Binding var selectedTab: OrderType
    let kitchen: Kitchen

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                OrderTypeButton(title: "Grab & Go", isSelected: selectedTab == .grabAndGo) {
                    selectedTab = .grabAndGo
                }
                OrderTypeButton(title: "Preorder", isSelected: selectedTab == .preorder) {
                    selectedTab = .preorder
                }
                OrderTypeButton(title: "Request", isSelected: selectedTab == .request) {
                    selectedTab = .request
                }
            }
            .padding(.vertical, 5)

            if selectedTab == .grabAndGo {
                GrabAndGoView(foodItems: kitchen.foodItems.filter { $0.numAvailable > 0 })
            } else if selectedTab == .preorder {
                PreorderView(highlightedDates: [Calendar.current.date(byAdding: .day, value: 1, to: Date())!])
            } else if selectedTab == .request {
                RequestView(foodItems: kitchen.foodItems)
            }
        }
    }
}




#Preview {
    let cartManager = CartManager()
    let sampleKitchen = sampleKitchens[0]
    KitchenDetailView(kitchen: sampleKitchen)
        .environmentObject(cartManager)
}
