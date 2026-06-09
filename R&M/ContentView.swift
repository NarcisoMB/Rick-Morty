//
//  ContentView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(LanguageManager.self) private var lang

    var body: some View {
        TabView {
            CharacterListView()
                .tabItem {
					Label(self.lang.localized(LocalizationKeys.Tab.characters), systemImage: "person.3")
                }
            FavoritesView()
                .tabItem {
					Label(self.lang.localized(LocalizationKeys.Tab.favorites), systemImage: "heart")
                }
			SettingsView()
				.tabItem {
					Label(self.lang.localized(LocalizationKeys.Tab.settings), systemImage: "gear")
				}
        }
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
        .environment(FavoritesManager.shared)
        .environment(BiometricAuthManager.shared)
}
