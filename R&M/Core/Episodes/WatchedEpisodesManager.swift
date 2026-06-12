//
//  WatchedEpisodesManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation
import Observation

@Observable
final class WatchedEpisodesManager {
    static let shared = WatchedEpisodesManager()

    private let repository: WatchedEpisodesRepositoryProtocol
    private(set) var watched: Set<Int>

    private init() {
        let repo = WatchedEpisodesRepository()
        self.repository = repo
        self.watched = repo.load()
    }

    init(repository: WatchedEpisodesRepositoryProtocol) {
        self.repository = repository
        self.watched = repository.load()
    }

    func toggle(_ episode: Int) {
		if self.watched.contains(episode) {
			self.watched.remove(episode)
        } else {
			self.watched.insert(episode)
        }
		self.repository.save(self.watched)
    }

    func isWatched(_ episode: Int) -> Bool {
		self.watched.contains(episode)
    }
}
