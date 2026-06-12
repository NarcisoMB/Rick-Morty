//
//  GetEpisodesUseCase.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

struct GetEpisodesUseCase {
    private let repository: EpisodeRepositoryProtocol

    init(repository: EpisodeRepositoryProtocol) {
        self.repository = repository
    }

    func execute(ids: [Int]) async throws -> [Episode] {
        try await repository.getEpisodes(ids: ids)
    }
}
