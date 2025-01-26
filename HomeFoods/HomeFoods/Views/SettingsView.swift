//
//  SettingsView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/25/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Button("Logout") {
                    appViewModel.logout()
                }
                .foregroundColor(.red)
            }

            Section(header: Text("App Preferences")) {
                Toggle("Chef Mode", isOn: $appViewModel.isChefMode)
            }

            Section(header: Text("About")) {
                Text("Version 1.0.0")
                Text("Developed by Andrew Li")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    let appViewModel = AppViewModel()
    SettingsView()
        .environmentObject(appViewModel)
}
