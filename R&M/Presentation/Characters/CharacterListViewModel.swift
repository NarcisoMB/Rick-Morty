//
//  CharactersViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import Foundation

@Observable
final class CharacterListViewModel {
    static let maxRetries = 3

    var characters: [Character] = []
    
	var isLoading = false
    var isLoadingMore = false
    var isRefreshing = false
    
	var currentPage = 1
    var totalPages = 0
    var retryAttempt = 0
    
	var alertError: String?
    var searchText = ""
    var filterStatus: String? = nil
    var filterSpecies: String? = nil

    var hasActiveFilter: Bool { filterStatus != nil || filterSpecies != nil }

    var availableStatuses: [String] { Array(Set(characters.map { $0.status })).sorted() }
    var availableSpecies:  [String] { Array(Set(characters.map { $0.species })).sorted() }

    var filteredCharacters: [Character] {
		var result = self.characters
		if !self.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
			let query = self.searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.status.lowercased().contains(query) ||
                $0.species.lowercased().contains(query)
            }
        }
		if let status = self.filterStatus {
            result = result.filter { $0.status == status }
        }
		if let species = self.filterSpecies {
            result = result.filter { $0.species == species }
        }
        return result
    }

    private let useCase: GetCharactersUseCase
    private var hasNextPage = true
    private var failedPage: Int?
    private var pendingRetryIsInitial = false

    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }

    func loadCharacters() async {
        guard !self.isLoading, self.characters.isEmpty else { return }
        self.isLoading = true
        self.alertError = nil
        self.currentPage = 1
        self.hasNextPage = true
        self.failedPage = nil

		await withRetry { [weak self] in
			guard let strongSelf = self else { return }
			
			let page = try await strongSelf.useCase.execute(page: 1)
			strongSelf.characters = page.characters
			strongSelf.hasNextPage = page.hasNextPage
			strongSelf.totalPages = page.totalPages
			CharacterStore.shared.add(page.characters)
			
		} onFailure: { [weak self] error in
			guard let strongSelf = self else { return }
			
			strongSelf.pendingRetryIsInitial = true
			strongSelf.alertError = error.localizedDescription
        }

        self.isLoading = false
    }

    func loadNextPageIfNeeded(currentItem: Character) async {
        guard
            self.hasNextPage,
            !self.isLoadingMore,
            self.searchText.trimmingCharacters(in: .whitespaces).isEmpty,
            currentItem.id == self.characters.last?.id
        else { return }
        // Setear flag antes de cualquier await para evitar race condition
        self.isLoadingMore = true
        await fetchNextPage(self.currentPage + 1)
    }

    func refresh() async {
        guard !isRefreshing, !isLoading else { return }
		self.isRefreshing = true
		self.alertError = nil

		let pagesToRefresh = max(self.currentPage, 1)
        var refreshed: [Character] = []

        for page in 1...pagesToRefresh {
            do {
				let result = try await self.useCase.execute(page: page, forceRefresh: true)
                refreshed += result.characters
                if page == pagesToRefresh {
					self.hasNextPage = result.hasNextPage
					self.totalPages = result.totalPages
                }
            } catch {
				self.alertError = error.localizedDescription
                break
            }
        }

        if !refreshed.isEmpty {
            self.characters = refreshed
            CharacterStore.shared.replace(refreshed)
        }
		self.isRefreshing = false
    }

    func retryFromAlert() async {
		self.alertError = nil
		if self.pendingRetryIsInitial {
			await self.loadCharacters()
        } else {
			guard let page = self.failedPage else { return }
            self.isLoadingMore = true
			await self.fetchNextPage(page)
        }
    }

    private func fetchNextPage(_ page: Int) async {
        self.alertError = nil
        self.failedPage = nil

        try? await Task.sleep(for: .seconds(1))

        await withRetry { [weak self] in
            guard let strongSelf = self else { return }
            
			let result = try await strongSelf.useCase.execute(page: page)
			strongSelf.characters += result.characters
			strongSelf.hasNextPage = result.hasNextPage
			strongSelf.totalPages = result.totalPages
			strongSelf.currentPage = page
			CharacterStore.shared.add(result.characters)
        } onFailure: { [weak self] error in
			guard let strongSelf = self else { return }
			
			strongSelf.pendingRetryIsInitial = false
			strongSelf.failedPage = page
			strongSelf.alertError = error.localizedDescription
        }

        self.isLoadingMore = false
    }

    private func withRetry(
        operation: () async throws -> Void,
        onFailure: (Error) -> Void
    ) async {
        var lastError: Error?
        for attempt in 1...Self.maxRetries {
            self.retryAttempt = attempt - 1
            do {
                try await operation()
                self.retryAttempt = 0
                return
            } catch let error as NetworkError where !error.isRetryable {
                onFailure(error)
                self.retryAttempt = 0
                return
            } catch {
                lastError = error
                NetworkLogger.logRetry(attempt: attempt, maxRetries: Self.maxRetries, error: error)
            }
        }
        NetworkLogger.logError(error: lastError ?? NetworkError.unknown(URLError(.unknown)))
        onFailure(lastError ?? NetworkError.unknown(URLError(.unknown)))
        self.retryAttempt = 0
    }
}
