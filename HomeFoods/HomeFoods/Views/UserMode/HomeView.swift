//
//  HomeView.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

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
                
                Spacer()
            }
            .navigationTitle("Home")
            .onAppear {
                appViewModel.fetchKitchens() // ✅ Fetch all kitchens
            }
            .refreshable {
                withAnimation {
                    appViewModel.fetchKitchens() // ✅ Refresh data with animation
                }
            }
        }
    }
}
