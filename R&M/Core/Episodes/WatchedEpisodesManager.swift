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

    private(set) var watched: Set<Int>

    private init() {
        let saved = UserDefaults.standard.array(forKey: "rm_watchedEpisodes") as? [Int] ?? []
		self.watched = Set(saved)
    }

    func toggle(_ episode: Int) {
		if self.watched.contains(episode) {
			self.watched.remove(episode)
        } else {
			self.watched.insert(episode)
        }
		UserDefaults.standard.set(Array(self.watched), forKey: "rm_watchedEpisodes")
    }

    func isWatched(_ episode: Int) -> Bool {
		self.watched.contains(episode)
    }
}
