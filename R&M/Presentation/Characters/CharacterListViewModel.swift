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

    var filteredCharacters: [Character] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return characters }
        let query = searchText.lowercased()
        return characters.filter {
            $0.name.lowercased().contains(query) ||
            $0.status.lowercased().contains(query) ||
            $0.species.lowercased().contains(query)
        }
    }

    private let useCase: GetCharactersUseCase
    private var hasNextPage = true
    private var failedPage: Int?
    private var pendingRetryIsInitial = false

    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }

    func loadCharacters() async {
        guard !self.isLoading else { return }
        self.isLoading = true
        self.alertError = nil
        self.currentPage = 1
        self.hasNextPage = true
        self.failedPage = nil

        await withRetry { [weak self] in
            guard let self else { return }
            let page = try await self.useCase.execute(page: 1)
            self.characters = page.characters
            self.hasNextPage = page.hasNextPage
            self.totalPages = page.totalPages
        } onFailure: { [weak self] error in
            self?.pendingRetryIsInitial = true
            self?.alertError = error.localizedDescription
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
        isRefreshing = true
        alertError = nil

        let pagesToRefresh = max(currentPage, 1)
        var refreshed: [Character] = []

        for page in 1...pagesToRefresh {
            do {
                let result = try await useCase.execute(page: page)
                refreshed += result.characters
                if page == pagesToRefresh {
                    hasNextPage = result.hasNextPage
                    totalPages = result.totalPages
                }
            } catch {
                alertError = error.localizedDescription
                break
            }
        }

        if !refreshed.isEmpty {
            characters = refreshed
        }
        isRefreshing = false
    }

    func retryFromAlert() async {
        alertError = nil
        if pendingRetryIsInitial {
            await loadCharacters()
        } else {
            guard let page = failedPage else { return }
            self.isLoadingMore = true
            await fetchNextPage(page)
        }
    }

    private func fetchNextPage(_ page: Int) async {
        self.alertError = nil
        self.failedPage = nil

        try? await Task.sleep(for: .seconds(1))

        await withRetry { [weak self] in
            guard let self else { return }
            let result = try await self.useCase.execute(page: page)
            self.characters += result.characters
            self.hasNextPage = result.hasNextPage
            self.totalPages = result.totalPages
            self.currentPage = page
        } onFailure: { [weak self] error in
            self?.pendingRetryIsInitial = false
            self?.failedPage = page
            self?.alertError = error.localizedDescription
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
