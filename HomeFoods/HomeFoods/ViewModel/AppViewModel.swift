//
//  AppViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Account?
    @Published var isChefMode: Bool = false
}
