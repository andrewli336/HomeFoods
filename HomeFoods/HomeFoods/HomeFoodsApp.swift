//
//  HomeFoodsApp.swift
//  HomeFoods
//
//  Created by Andrew Li on 12/23/24.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import GoogleSignIn
import Stripe

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = TestBackend.shared.getPublishableKey()
        return true
    }
    
    // This is required to handle the URL that your application receives at the end of the Google authentication process
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // For older iOS versions
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // This method is called when your app is opened via universal link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            return GIDSignIn.sharedInstance.handle(url)
        }
        return false
    }
}

@main
struct HomeFoodsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject var notificationViewModel = NotificationViewModel()
    
    init() {
        // This sets a dummy key initially, which will be replaced with the real key from the backend
        StripeAPI.defaultPublishableKey = "pk_test_51R19tUGd1SbjqZlmZbF4lPpTX8lI1IthtI3HhzLOVsN8iJ2NMuxbATqQPYinkkFPuDBz1YTlmJ3F12Po6SeaT1CD00Jrgy7o6N"
    }
    
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
                        .environmentObject(locationManager)
                        .environmentObject(orderViewModel)
                        .environmentObject(notificationViewModel)
                }
            } else {
                AuthView()
                    .environmentObject(appViewModel)
            }
        }
    }
}
