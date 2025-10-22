//
//  Urge_Watch_AppApp.swift
//  Urge Watch App
//
//  Created by Jens Eklund Håkansson on 2025-10-22.
//

import SwiftUI

@main
struct Urge_Watch_AppApp: App {
    init() {
        // Initialize Watch Connectivity on app launch
        _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
