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
    
	@FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
			VStack(spacing: 0) {
                // Barra de búsqueda — solo visible cuando showSearch = true
				if self.showSearch {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
						TextField(self.lang.localized(LocalizationKeys.CharacterList.searchPlaceholder), text: self.$viewModel.searchText)
                            .focused(self.$isSearchFocused)
                            .autocorrectionDisabled()
                            .onSubmit { self.showSearch = false }
                        if !self.viewModel.searchText.isEmpty {
                            Button {
                                self.viewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
					.onChange(of: self.isSearchFocused) { _, focused in
                        if !focused {
                            withAnimation(.easeInOut(duration: 0.2)) {
								self.showSearch = false
                            }
                        }
                    }
                }

                // Contenido principal
                if self.viewModel.isLoading {
                    Spacer()
                    ProgressView(self.viewModel.retryAttempt > 0
								 ? LocalizationKeys.retrying(attempt: self.viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: self.lang)
								 : self.lang.localized(LocalizationKeys.CharacterList.loading)
                    )
                    Spacer()
                } else {
					// Chip de filtro activo — visible cuando hay texto pero barra oculta
					if !self.showSearch && !self.viewModel.searchText.isEmpty {
						HStack(spacing: 4) {
							Image(systemName: "line.3.horizontal.decrease.circle.fill")
								.font(.caption)
							Text(self.viewModel.searchText)
								.font(.caption)
								.lineLimit(1)
							Button {
								self.viewModel.searchText = ""
							} label: {
								Image(systemName: "xmark")
									.font(.caption2)
									.bold()
							}
						}
						.padding(.horizontal, 10)
						.padding(.vertical, 6)
						.background(Color.accentColor.opacity(0.15))
						.foregroundStyle(Color.accentColor)
						.clipShape(Capsule())
						.padding(.horizontal)
						.padding(.vertical, 8)
						.frame(maxWidth: .infinity, alignment: .leading)
						.transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .leading)))
						.onTapGesture {
							withAnimation(.easeInOut(duration: 0.2)) {
								self.showSearch = true
							}
							// Activar foco en el siguiente ciclo de run loop
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
								self.isSearchFocused = true
							}
						}
					}
					
                    List {
                        ForEach(self.viewModel.filteredCharacters) { character in
                            CharacterRow(character: character)
                                .onAppear {
                                    if character == self.viewModel.characters.last {
                                        Task { await self.viewModel.loadNextPageIfNeeded(currentItem: character) }
                                    }
                                }
                                .listRowSeparator(.hidden)
                        }
						VStack(content: {
							if self.viewModel.isLoadingMore {
								HStack(spacing: 8) {
									ProgressView()
									if self.viewModel.retryAttempt > 0 {
										Text(LocalizationKeys.retrying(attempt: self.viewModel.retryAttempt, of: CharacterListViewModel.maxRetries, lang: self.lang))
											.font(.caption)
											.foregroundStyle(.secondary)
									}
								}
								.padding(.vertical, 10)
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
						})
                    }
                    .refreshable { await self.viewModel.refresh() }
                }
            }
			.animation(.easeInOut(duration: 0.2), value: self.showSearch)
            .animation(.easeInOut(duration: 0.2), value: self.viewModel.searchText.isEmpty)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
							self.showSearch.toggle()
                        }
						if self.showSearch { self.isSearchFocused = true }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .task { await self.viewModel.loadCharacters() }
            .alert(
				Text(self.lang.localized(LocalizationKeys.CharacterList.connectionError)),
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
                message: {
                    Text(self.viewModel.alertError ?? "")
                }
            )
			.navigationTitle("Rick & Morty")
			.navigationSubtitle(self.lang.localized(LocalizationKeys.CharacterList.subtitle))
        }
		.overlay {
			if self.viewModel.isRefreshing {
				ZStack {
					Color.black.opacity(0.75)
						.ignoresSafeArea()
					GIFImageView(name: "loadingPortal")
						.frame(width: 160, height: 160)
				}
				.transition(.opacity.animation(.easeInOut(duration: 0.2)))
			}
		}
    }
}

private struct CharacterRow: View {
    let character: Character

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: self.character.image) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(self.character.name)
                    .font(.headline)
                Text(self.character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(self.character.status)
                    .font(.caption)
                    .foregroundStyle(self.statusColor)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch character.status.lowercased() {
        case "alive": .green
        case "dead":  .red
        default:      .gray
        }
    }
}

#Preview {
    CharacterListView()
}
