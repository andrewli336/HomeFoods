//
//  HomeFoodsApp.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct HomeFoodsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            if appViewModel.isAuthenticated {
                if appViewModel.showOnboarding {
                    OnboardingView()
                        .environmentObject(appViewModel)
                } else if appViewModel.showChefSetupView {
                    // Show Chef Setup View after onboarding (if user wants to be a chef)
                    ChefSetupView()
                        .environmentObject(appViewModel)
                } else if appViewModel.showTutorialView {
                    TutorialView()
                        .environmentObject(appViewModel)
                } else {
                    ContentView()
                        .environmentObject(appViewModel)
                }
            } else {
                AuthView()
                    .environmentObject(appViewModel)
            }
        }
    }
}
