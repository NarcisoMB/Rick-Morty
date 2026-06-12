//
//  EpisodeRepositoryProtocol.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

protocol EpisodeRepositoryProtocol {
    func getEpisodes(ids: [Int]) async throws -> [Episode]
}
