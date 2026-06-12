//
//  FavoriteRepository.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let key = "rm_favorites"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> [Character] {
        guard
            let data = userDefaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Character].self, from: data)
        else { return [] }
        return decoded
    }

    func save(_ characters: [Character]) {
        guard let data = try? JSONEncoder().encode(characters) else { return }
        userDefaults.set(data, forKey: key)
    }
}
