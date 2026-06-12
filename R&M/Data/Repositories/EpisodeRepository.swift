//
//  EpisodeRepository.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

final class EpisodeRepository: EpisodeRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient()) {
        self.client = client
    }

    func getEpisodes(ids: [Int]) async throws -> [Episode] {
        guard !ids.isEmpty else { return [] }
        let response: EpisodeResponseDTO = try await client.get(.episodes(ids: ids))
        return response.items.map { $0.toDomain() }
    }
}
