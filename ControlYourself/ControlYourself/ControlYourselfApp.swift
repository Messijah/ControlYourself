//
//  ControlYourselfApp.swift
//  ControlYourself
//
//  Created by Jens on 2024-03-29.
//

import SwiftUI

@main
struct ControlYourselfApp: App {
    @ObservedObject private var languageManager = LanguageManager.shared

    init() {
        // Swizzle Bundle.main so all NSLocalizedString calls use the selected language
        LanguageManager.setupBundleSwizzling()
        // Initialize Watch Connectivity on app launch
        _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageManager.refreshID) // Force full view rebuild on language change
        }
    }
}
