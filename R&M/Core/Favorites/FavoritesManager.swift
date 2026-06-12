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

    private let repository: FavoriteRepositoryProtocol
    private(set) var favorites: [Character] = []

    private init() {
        self.repository = FavoriteRepository()
        self.favorites = self.repository.load()
        if ProcessInfo.processInfo.environment["UI_TESTING_BYPASS_AUTH"] != nil {
            self.favorites = []
            self.repository.save([])
        }
    }

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
        self.favorites = repository.load()
    }

    func toggle(_ character: Character) {
        if self.isFavorite(character) {
            self.favorites.removeAll { $0.id == character.id }
        } else {
            self.favorites.append(character)
        }
        self.repository.save(self.favorites)
    }

    func isFavorite(_ character: Character) -> Bool {
        self.favorites.contains { $0.id == character.id }
    }
}
