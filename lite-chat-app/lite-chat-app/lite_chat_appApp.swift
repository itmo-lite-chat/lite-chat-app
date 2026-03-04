//
//  lite_chat_appApp.swift
//  lite-chat-app
//
//  Created by a on 04.03.2026.
//

import SwiftUI

@main
struct lite_chat_appApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .animation(.easeInOut(duration: 0.3), value: appState.isLoggedIn)
        }
    }
}
