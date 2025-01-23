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
    var kitchenId: String? // ID of the kitchen the user manages, if they are a chef
}



