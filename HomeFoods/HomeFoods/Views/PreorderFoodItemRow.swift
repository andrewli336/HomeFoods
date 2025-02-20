//
//  PreorderFoodItemRow.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/19/25.
//

import SwiftUI

struct PreorderFoodItemRow: View {
    let foodItem: FoodItem
    let availableTimes: [String]
    @State private var showSheet = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Food item details
            VStack(alignment: .leading, spacing: 8) {
                Text(foodItem.name)
                    .font(.headline)
                Text(foodItem.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Text("$\(foodItem.cost, specifier: "%.2f") • \(Image(systemName: "hand.thumbsup")) \(Int(foodItem.rating))% (\(foodItem.numRatings))")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                // Available times chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableTimes, id: \.self) { time in
                            Text(time)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // Image section with plus button
            ZStack {
                if let imageUrl = foodItem.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                                .clipped()
                        } else if phase.error != nil {
                            Color.red
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                                .overlay(Text("Error").foregroundColor(.white))
                        } else {
                            ProgressView()
                                .frame(width: 150, height: 150)
                        }
                    }
                } else {
                    Color.gray
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .overlay(Text("No Image").foregroundColor(.white))
                }
                
                // Plus button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 25, height: 25)
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .offset(x: -10, y: -10)
                    }
                }
            }
            .frame(width: 150, height: 150)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .onTapGesture {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            PreorderFoodItemSheet(foodItem: foodItem, availableTimes: availableTimes, isPresented: $showSheet)
                .presentationDetents([.large])
        }
    }
}
