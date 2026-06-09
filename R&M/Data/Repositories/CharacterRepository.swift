//
//  CharacterRepository.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

final class CharacterRepository: CharacterRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }

    func getCharacters(page: Int) async throws -> CharacterPage {
        let response: CharacterResponseDTO = try await client.get(.characters(page: page))
        return CharacterPage(
            characters: response.results.map { $0.toDomain() },
            hasNextPage: response.info.next != nil,
            totalPages: response.info.pages
        )
    }
}
