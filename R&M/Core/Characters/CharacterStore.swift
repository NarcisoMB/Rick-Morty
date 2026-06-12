//
//  CharacterStore.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Observation

@Observable final class CharacterStore {
    static let shared = CharacterStore()

    private(set) var characters: [Character] = []

    func add(_ characters: [Character]) {
        let existing = Set(self.characters.map { $0.id })
        let new = characters.filter { !existing.contains($0.id) }
        guard !new.isEmpty else { return }
        self.characters.append(contentsOf: new)
    }

    func replace(_ characters: [Character]) {
        self.characters = characters
    }

    func reset() {
        self.characters = []
    }
}
