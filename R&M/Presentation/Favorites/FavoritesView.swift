//
//  FavoritesView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI

struct FavoritesView: View {
	let isTabSelected: Bool
	
	@Environment(LanguageManager.self) private var lang
	@Environment(FavoritesManager.self) private var favorites
	@Environment(BiometricAuthManager.self) private var biometricAuth
	
	@State private var isUnlocked = false
	@State private var authTask: Task<Void, Never>?
	@State private var showSearch = false
	@State private var searchText = ""
	@State private var filterStatus: String?
	@State private var filterSpecies: String?
	@State private var selectedCharacter: Character?
	
	@FocusState private var isSearchFocused: Bool
	
	private var availableStatuses: [String] { Array(Set(self.favorites.favorites.map { $0.status })).sorted() }
	private var availableSpecies: [String] { Array(Set(self.favorites.favorites.map { $0.species })).sorted() }
	
	private var filtered: [Character] {
		var result = self.favorites.favorites
		if !self.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
			let query = self.searchText.lowercased()
			result = result.filter {
				$0.name.lowercased().contains(query) ||
				$0.status.lowercased().contains(query) ||
				$0.species.lowercased().contains(query)
			}
		}
		if let status = self.filterStatus { result = result.filter { $0.status == status } }
		if let species = self.filterSpecies { result = result.filter { $0.species == species } }
		return result
	}
	
	var body: some View {
		Group {
			if !self.isUnlocked {
				lockScreen
			} else {
				mainContent
			}
		}
		.onChange(of: isTabSelected, initial: true) { _, selected in
			if selected {
				self.authTask?.cancel()
				self.authTask = Task { await self.attemptUnlock() }
			} else {
				self.authTask?.cancel()
				self.authTask = nil
				self.isUnlocked = false
			}
		}
	}
	
	private var lockScreen: some View {
		VStack(spacing: 24) {
			Image(systemName: "lock.fill")
				.font(.system(size: 56))
				.foregroundStyle(.secondary)
			Text(self.lang.localized(LocalizationKeys.Favorites.lockedTitle))
				.font(.title2).bold()
			Button {
				Task { await self.attemptUnlock() }
			} label: {
				Label(self.lang.localized(LocalizationKeys.Favorites.unlockButton), systemImage: "faceid")
					.font(.headline)
					.padding(.horizontal, 28)
					.padding(.vertical, 14)
					.background(Color.accentColor)
					.foregroundStyle(.white)
					.clipShape(Capsule())
			}
			.accessibilityIdentifier("btn_unlock")
		}
		.accessibilityElement(children: .contain)
		.accessibilityIdentifier("screen_locked")
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.rmBackground)
		.colorScheme(.dark)
	}
	
	private var mainContent: some View {
		NavigationStack {
			Group {
				if self.favorites.favorites.isEmpty {
					ContentUnavailableView(
						self.lang.localized(LocalizationKeys.Favorites.emptyTitle),
						systemImage: "heart.slash",
						description: Text(self.lang.localized(LocalizationKeys.Favorites.emptyDescription))
					)
					.accessibilityIdentifier("view_favorites_empty")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color.rmBackground)
				} else {
					ScrollView {
						LazyVStack(spacing: 8) {
							ForEach(self.filtered) { character in
								CharacterRow(character: character)
									.onTapGesture { self.selectedCharacter = character }
									.padding(.horizontal, 8)
							}
						}
						.padding(.vertical, 4)
					}
					.accessibilityIdentifier("list_favorites")
					.background(Color.rmBackground)
				}
			}
			.sheet(item: self.$selectedCharacter) {
				CharacterDetailView(character: $0)
			}
			.safeAreaInset(edge: .top, spacing: 0) {
				SearchFilterHeader(
					showSearch: self.$showSearch,
					searchText: self.$searchText,
					filterStatus: self.$filterStatus,
					filterSpecies: self.$filterSpecies,
					availableStatuses: self.availableStatuses,
					availableSpecies: self.availableSpecies,
					isSearchFocused: self.$isSearchFocused
				)
			}
			.colorScheme(.dark)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						self.lang.setLanguage(lang.language == "en" ? "es" : "en")
					} label: {
						Text(self.lang.language == "en" ? "ES" : "EN").bold()
					}
				}
				ToolbarSpacer(.flexible)
				ToolbarItem {
					VStack(spacing: 2) {
						Text("Rick & Morty")
							.foregroundStyle(.white)
						Text(self.lang.localized(LocalizationKeys.Favorites.subtitle))
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
	}
	
	private func attemptUnlock() async {
		switch ProcessInfo.processInfo.environment["UI_TESTING_BYPASS_AUTH"] {
		case "1": self.isUnlocked = true; return
		case "0": return  // stay locked in UI tests
		default: break
		}
		let reason = self.lang.localized(LocalizationKeys.Favorites.authReason)
		let result = await self.biometricAuth.authenticate(reason: reason)
		guard !Task.isCancelled else { return }
		self.isUnlocked = result
	}
}
