//
//  WatchedEpisodesRepository.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

final class WatchedEpisodesRepository: WatchedEpisodesRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let key = "rm_watchedEpisodes"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> Set<Int> {
        let saved = userDefaults.array(forKey: key) as? [Int] ?? []
        return Set(saved)
    }

    func save(_ episodes: Set<Int>) {
        userDefaults.set(Array(episodes), forKey: key)
    }
}
