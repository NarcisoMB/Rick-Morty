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
					ForEach(self.viewModel.filteredCharacters) { character in
                        CharacterRow(character: character)
							.onTapGesture { self.selectedCharacter = character }
                            .onAppear {
								if character == self.viewModel.characters.last {
									Task { await self.viewModel.loadNextPageIfNeeded(currentItem: character) }
                                }
                            }
                            .padding(.horizontal, 8)
                    }
                    footer
                }
                .padding(.vertical, 4)
            }
            .background(Color.rmBackground)
			.refreshable { await self.viewModel.refresh() }
			.sheet(item: self.$selectedCharacter) { CharacterDetailView(character: $0) }
			.overlay { self.loadingOverlay }
            .safeAreaInset(edge: .top, spacing: 0) {
                SearchFilterHeader(
					showSearch: self.$showSearch,
					searchText: self.$viewModel.searchText,
					filterStatus: self.$viewModel.filterStatus,
					filterSpecies: self.$viewModel.filterSpecies,
					availableStatuses: self.viewModel.availableStatuses,
					availableSpecies: self.viewModel.availableSpecies,
					isSearchFocused: self.$isSearchFocused
                )
            }
            .colorScheme(.dark)
			.task { await self.viewModel.loadCharacters() }
            .alert(
                Text(lang.localized(LocalizationKeys.CharacterList.connectionError)),
                isPresented: Binding(
					get: { self.viewModel.alertError != nil },
					set: { if !$0 { self.viewModel.alertError = nil } }
                ),
                actions: {
					Button(self.lang.localized(LocalizationKeys.CharacterList.retry)) {
						Task { await self.viewModel.retryFromAlert() }
                    }
					Button(self.lang.localized(LocalizationKeys.CharacterList.cancel), role: .cancel) {}
                },
				message: { Text(self.viewModel.alertError ?? "") }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
						self.lang.setLanguage(self.lang.language == "en" ? "es" : "en")
                    } label: {
						Text(self.lang.language == "en" ? "ES" : "EN").bold()
                    }
                }
                ToolbarSpacer(.flexible)
                ToolbarItem {
                    VStack {
                        Text("Rick & Morty")
							.foregroundStyle(.white)
						Text(self.lang.localized(LocalizationKeys.CharacterList.subtitle))
							.foregroundStyle(.white)
							.font(.caption)
                    }
                    .frame(maxWidth: .infinity)
					.padding(.vertical, 8)
                }
                ToolbarSpacer(.flexible)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
						withAnimation(.easeInOut(duration: 0.2)) { self.showSearch.toggle() }
						if self.showSearch { self.isSearchFocused = true }
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
			if self.viewModel.isRefreshing {
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
			if self.viewModel.isLoadingMore {
                HStack(spacing: 8) {
                    ProgressView()
					if self.viewModel.retryAttempt > 0 {
						Text(LocalizationKeys.retrying(attempt: self.viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: self.lang))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
				.animation(.easeInOut(duration: 0.25), value: self.viewModel.isLoadingMore)
            }
			if self.viewModel.totalPages > 0 && self.viewModel.searchText.isEmpty {
				Text(LocalizationKeys.pageIndicator(current: self.viewModel.currentPage, total: self.viewModel.totalPages, lang: self.lang))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
		if self.viewModel.isLoading {
            ZStack {
                Color.rmBackground
				ProgressView(self.viewModel.retryAttempt > 0
							 ? LocalizationKeys.retrying(attempt: self.viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: self.lang)
							 : self.lang.localized(LocalizationKeys.CharacterList.loading))
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
