//
//  FavoriteCuisinesPage.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import SwiftUI

struct FavoriteCuisinesPage: View {
    @Binding var selectedCuisines: [String]
    var nextPage: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("What are your favorite cuisines?")
                .font(.headline)
                .padding()

            ScrollView {
                ForEach(availableCuisines, id: \.self) { cuisine in
                    HStack {
                        Text(cuisine)
                            .font(.body)
                        Spacer()
                        Image(systemName: selectedCuisines.contains(cuisine) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedCuisines.contains(cuisine) ? .green : .gray)
                            .onTapGesture {
                                if selectedCuisines.contains(cuisine) {
                                    selectedCuisines.removeAll { $0 == cuisine }
                                } else {
                                    selectedCuisines.append(cuisine)
                                }
                            }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                }
            }
            .padding()

            Spacer()

            Button(action: nextPage) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
