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
        if isFavorite(character) {
            favorites.removeAll { $0.id == character.id }
        } else {
            favorites.append(character)
        }
        save()
    }

    func isFavorite(_ character: Character) -> Bool {
        favorites.contains { $0.id == character.id }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        UserDefaults.standard.set(data, forKey: "rm_favorites")
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: "rm_favorites"),
            let decoded = try? JSONDecoder().decode([Character].self, from: data)
        else { return }
        favorites = decoded
    }
}
