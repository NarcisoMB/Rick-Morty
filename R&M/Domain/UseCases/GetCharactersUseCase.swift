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

    func execute(page: Int = 1) async throws -> CharacterPage {
        try await repository.getCharacters(page: page)
    }
}
