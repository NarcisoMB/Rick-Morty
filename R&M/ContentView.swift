//
//  ContentView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CharacterListView()
                .tabItem {
                    Label("Characters", systemImage: "person.3")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
        .environment(FavoritesManager.shared)
}
