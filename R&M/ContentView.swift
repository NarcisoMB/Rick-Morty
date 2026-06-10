//
//  ContentView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(MapNavigationManager.self) private var mapNav

    @State private var selectedTab = 0
    @State private var showSplash = true

    var body: some View {
        ZStack {
            tabContent
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(.easeOut(duration: 0.6)) { showSplash = false }
        }
        .onChange(of: mapNav.pendingCharacter) { _, character in
            if character != nil { selectedTab = 2 }
        }
    }

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            CharacterListView()
                .tag(0)
                .tabItem {
                    Label(self.lang.localized(LocalizationKeys.Tab.characters), systemImage: "person.3")
                }
            FavoritesView(isTabSelected: selectedTab == 1)
                .tag(1)
                .tabItem {
                    Label(self.lang.localized(LocalizationKeys.Tab.favorites), systemImage: "heart")
                }
            CharacterMapView()
                .tag(2)
                .tabItem {
                    Label(self.lang.localized(LocalizationKeys.Tab.map), systemImage: "map")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(ToastManager.shared)
        .environment(LanguageManager.shared)
        .environment(FavoritesManager.shared)
        .environment(BiometricAuthManager.shared)
        .environment(WatchedEpisodesManager.shared)
        .environment(MapNavigationManager.shared)
        .environment(LocationManager.shared)
}
