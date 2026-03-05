//
//  ContentView.swift
//  lite-chat-app
//
//  Created by a on 04.03.2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isLoggedIn {
            TabView {
                ChatListView()
                    .tabItem {
                        Label("Чаты", systemImage: "bubble.left.and.bubble.right")
                    }
                SettingsView()
                    .tabItem {
                        Label("Настройки", systemImage: "gearshape")
                    }
            }
            .transition(.opacity)
        } else {
            LoginView()
                .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
