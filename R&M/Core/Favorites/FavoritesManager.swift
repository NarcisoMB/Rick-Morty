//
//  FavoritesManager.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation
import Foundation

@Observable final class FavoritesManager {
    static let shared = FavoritesManager()

    private(set) var favorites: [Character] = []

    private init() { load() }

    func toggle(_ character: Character) {
		if self.isFavorite(character) {
			self.favorites.removeAll { $0.id == character.id }
        } else {
			self.favorites.append(character)
        }
		self.save()
    }

    func isFavorite(_ character: Character) -> Bool {
		self.favorites.contains { $0.id == character.id }
    }

    private func save() {
		guard let data = try? JSONEncoder().encode(self.favorites) else { return }
        UserDefaults.standard.set(data, forKey: "rm_favorites")
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: "rm_favorites"),
            let decoded = try? JSONDecoder().decode([Character].self, from: data)
        else { return }
		self.favorites = decoded
    }
}
