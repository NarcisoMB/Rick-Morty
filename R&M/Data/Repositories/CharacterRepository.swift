//
//  CharacterRepository.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

final class CharacterRepository: CharacterRepositoryProtocol {
    private let client: HTTPClientProtocol
    private let local: CharacterLocalDataSource

    init(
        client: HTTPClientProtocol = HTTPClient(),
        local: CharacterLocalDataSource = CharacterLocalDataSource()
    ) {
        self.client = client
        self.local = local
    }

    func getCharacters(page: Int, forceRefresh: Bool = false) async throws -> CharacterPage {
        if !forceRefresh {
            let cached = self.local.fetchCharacters(page: page)
            if !cached.isEmpty {
                return CharacterPage(characters: cached, hasNextPage: true, totalPages: 0)
            }
        }
        do {
            let response: CharacterResponseDTO = try await self.client.get(.characters(page: page))
            let characters = response.results.map { $0.toDomain() }
            self.local.save(characters: characters, page: page)
            return CharacterPage(
                characters: characters,
                hasNextPage: response.info.next != nil,
                totalPages: response.info.pages
            )
        } catch {
            let cached = self.local.fetchCharacters(page: page)
            guard !cached.isEmpty else { throw error }
            return CharacterPage(characters: cached, hasNextPage: true, totalPages: 0)
        }
    }
}
