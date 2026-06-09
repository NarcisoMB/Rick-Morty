//
//  CharactersView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct CharacterListView: View {
    @Environment(LanguageManager.self) private var lang

    @State private var viewModel = CharacterListViewModel()
    @State private var showSearch = false
    @State private var selectedCharacter: Character?

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.filteredCharacters) { character in
                        CharacterRow(character: character)
                            .onTapGesture { selectedCharacter = character }
                            .onAppear {
                                if character == viewModel.characters.last {
                                    Task { await viewModel.loadNextPageIfNeeded(currentItem: character) }
                                }
                            }
                            .padding(.horizontal, 8)
                    }
                    footer
                }
                .padding(.vertical, 4)
            }
            .background(Color.rmBackground)
            .refreshable { await viewModel.refresh() }
            .sheet(item: $selectedCharacter) { CharacterDetailView(character: $0) }
            .overlay { loadingOverlay }
            .safeAreaInset(edge: .top, spacing: 0) {
                SearchFilterHeader(
                    showSearch: $showSearch,
                    searchText: $viewModel.searchText,
                    filterStatus: $viewModel.filterStatus,
                    filterSpecies: $viewModel.filterSpecies,
                    availableStatuses: viewModel.availableStatuses,
                    availableSpecies: viewModel.availableSpecies,
                    isSearchFocused: $isSearchFocused
                )
            }
            .colorScheme(.dark)
            .task { await viewModel.loadCharacters() }
            .alert(
                Text(lang.localized(LocalizationKeys.CharacterList.connectionError)),
                isPresented: Binding(
                    get: { viewModel.alertError != nil },
                    set: { if !$0 { viewModel.alertError = nil } }
                ),
                actions: {
                    Button(lang.localized(LocalizationKeys.CharacterList.retry)) {
                        Task { await viewModel.retryFromAlert() }
                    }
                    Button(lang.localized(LocalizationKeys.CharacterList.cancel), role: .cancel) {}
                },
                message: { Text(viewModel.alertError ?? "") }
            )
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
                    VStack {
                        Text("Rick & Morty").foregroundStyle(.white)
                        Text(lang.localized(LocalizationKeys.CharacterList.subtitle)).foregroundStyle(.white)
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
        .overlay {
            if viewModel.isRefreshing {
                ZStack {
                    Color.black.opacity(0.75).ignoresSafeArea()
                    GIFImageView(name: "loadingPortal")
                        .frame(width: 160, height: 160)
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingMore {
                HStack(spacing: 8) {
                    ProgressView()
                    if viewModel.retryAttempt > 0 {
                        Text(LocalizationKeys.retrying(attempt: viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: lang))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.25), value: viewModel.isLoadingMore)
            }
            if viewModel.totalPages > 0 && viewModel.searchText.isEmpty {
                Text(LocalizationKeys.pageIndicator(current: viewModel.currentPage, total: viewModel.totalPages, lang: lang))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ZStack {
                Color.rmBackground
                ProgressView(viewModel.retryAttempt > 0
                             ? LocalizationKeys.retrying(attempt: viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: lang)
                             : lang.localized(LocalizationKeys.CharacterList.loading))
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    CharacterListView()
        .environment(LanguageManager.shared)
        .environment(FavoritesManager.shared)
}
