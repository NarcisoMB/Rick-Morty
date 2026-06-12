//
//  EpisodeListViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation

@Observable
final class EpisodeListViewModel {
    private(set) var episodes: [Episode] = []
    private(set) var isLoading = false

    private let useCase: GetEpisodesUseCase

    init(useCase: GetEpisodesUseCase = GetEpisodesUseCase(repository: EpisodeRepository())) {
        self.useCase = useCase
    }

    func load(ids: [Int]) async {
        guard !ids.isEmpty else { return }
        isLoading = true
        do {
            episodes = try await useCase.execute(ids: ids)
        } catch {
            episodes = []
        }
        isLoading = false
    }
}
