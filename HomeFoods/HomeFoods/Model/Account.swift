//
//  Account.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Account: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let name: String // User's display name
    let email: String // User's email address
    let profilePictureUrl: String? // Optional URL for profile picture
    let accountCreationDate: Date // Date when the account was created
    var isChef: Bool // Whether the user is a chef
    var isAdmin: Bool
    var kitchenId: String? // ID of the kitchen the user manages, if they are a chef
    var favoriteCuisines: [String]? // User's favorite cuisines
    var howHeardAboutUs: String? // How the user heard about the app
    var address: String?
}

let availableCuisines = ["Chinese", "Italian", "Mexican", "Indian", "Japanese", "Thai", "French"]
let howHeardOptions = ["From a friend", "From an ad", "From the App Store", "Other"]



