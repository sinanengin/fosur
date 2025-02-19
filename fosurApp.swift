//
//  fosurApp.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 4.02.2025.
//

import SwiftUI

@main
struct fosurApp: App {
    @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(appState)
        }
    }
}
#Preview {
    SplashScreenView()
}
