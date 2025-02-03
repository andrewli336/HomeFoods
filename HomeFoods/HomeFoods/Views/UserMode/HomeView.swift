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
    @EnvironmentObject var locationManager: LocationManager
    @State private var sortedKitchens: [Kitchen] = [] // ✅ Store sorted kitchens

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Discover Kitchens")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(sortedKitchens) { kitchen in
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
                fetchAndSortKitchens()
            }
            .refreshable {
                withAnimation {
                    fetchAndSortKitchens() // ✅ Refresh data
                }
            }
        }
    }

    /// **📌 Fetch kitchens and sort them by distance**
    private func fetchAndSortKitchens() {
        appViewModel.fetchKitchens {
            DispatchQueue.main.async {
                self.sortedKitchens = locationManager.getSortedKitchens(appViewModel.kitchens)
            }
        }
    }
}
