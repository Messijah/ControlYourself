//
//  ControlYourselfApp.swift
//  ControlYourself
//
//  Created by Jens on 2024-03-29.
//

import SwiftUI

@main
struct ControlYourselfApp: App {
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
