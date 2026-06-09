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
                    Label(lang.localized(LocalizationKeys.Tab.characters), systemImage: "person.3")
                }
            FavoritesView()
                .tabItem {
                    Label(lang.localized(LocalizationKeys.Tab.favorites), systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
        .environment(FavoritesManager.shared)
}
