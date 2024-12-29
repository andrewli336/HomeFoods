//
//  HomeFoodsApp.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI

@main
struct HomeFoodsApp: App {
    @StateObject private var cartManager = CartManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartManager)
        }
    }
}
