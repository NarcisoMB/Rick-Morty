//
//  GetCharactersUseCase.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

struct GetCharactersUseCase {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int = 1, forceRefresh: Bool = false) async throws -> CharacterPage {
		try await self.repository.getCharacters(page: page, forceRefresh: forceRefresh)
    }
}
