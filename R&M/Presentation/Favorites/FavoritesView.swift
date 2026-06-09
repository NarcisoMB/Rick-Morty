//
//  FavoritesView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(LanguageManager.self) private var lang
    @Environment(FavoritesManager.self) private var favorites

    @State private var showSearch = false
    @State private var searchText = ""
    @State private var filterStatus: String? = nil
    @State private var filterSpecies: String? = nil
    @State private var selectedCharacter: Character?

    @FocusState private var isSearchFocused: Bool

    private var availableStatuses: [String] { Array(Set(favorites.favorites.map { $0.status })).sorted() }
    private var availableSpecies:  [String] { Array(Set(favorites.favorites.map { $0.species })).sorted() }

    private var filtered: [Character] {
        var result = favorites.favorites
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.status.lowercased().contains(query) ||
                $0.species.lowercased().contains(query)
            }
        }
        if let status = filterStatus   { result = result.filter { $0.status == status } }
        if let species = filterSpecies { result = result.filter { $0.species == species } }
        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if favorites.favorites.isEmpty {
                    ContentUnavailableView(
                        lang.localized(LocalizationKeys.Favorites.emptyTitle),
                        systemImage: "heart.slash",
                        description: Text(lang.localized(LocalizationKeys.Favorites.emptyDescription))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.rmBackground)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filtered) { character in
                                CharacterRow(character: character)
                                    .onTapGesture { selectedCharacter = character }
                                    .padding(.horizontal, 8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .background(Color.rmBackground)
                }
            }
            .sheet(item: $selectedCharacter) { CharacterDetailView(character: $0) }
            .safeAreaInset(edge: .top, spacing: 0) {
                SearchFilterHeader(
                    showSearch: $showSearch,
                    searchText: $searchText,
                    filterStatus: $filterStatus,
                    filterSpecies: $filterSpecies,
                    availableStatuses: availableStatuses,
                    availableSpecies: availableSpecies,
                    isSearchFocused: $isSearchFocused
                )
            }
            .colorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        lang.setLanguage(lang.language == "en" ? "es" : "en")
                    } label: {
                        Text(lang.language == "en" ? "ES" : "EN").bold()
                    }
                }
                ToolbarSpacer(.flexible)
                ToolbarItem {
                    VStack(spacing: 2) {
                        Text("Rick & Morty").foregroundStyle(.white)
                        Text(lang.localized(LocalizationKeys.Favorites.subtitle)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                ToolbarSpacer(.flexible)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { showSearch.toggle() }
                        if showSearch { isSearchFocused = true }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .toolbarBackground(Color.rmBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
