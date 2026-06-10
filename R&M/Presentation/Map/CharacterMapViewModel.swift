//
//  CharacterMapViewModel.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import CoreLocation
import Observation

@Observable
final class CharacterMapViewModel {
    private(set) var isLoading = false

    private let store: CharacterStore
    private let useCase: GetCharactersUseCase

    init(
        useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository()),
        store: CharacterStore = .shared
    ) {
        self.useCase = useCase
        self.store = store
    }

    var annotations: [CharacterAnnotation] {
        store.characters.map {
            CharacterAnnotation(
				id: $0.id,
				character: $0,
				coordinate: Self.coordinate(for: $0.id)
			)
        }
    }

    func load() async {
        guard store.characters.isEmpty else { return }
        isLoading = true
        for page in 1...3 {
            guard let result = try? await useCase.execute(page: page) else { break }
            store.add(result.characters)
            if !result.hasNextPage { break }
        }
        isLoading = false
    }

    static func coordinate(for id: Int) -> CLLocationCoordinate2D {
        // Wang hash — full avalanche, no visible pattern between sequential IDs
        var hash = UInt32(bitPattern: Int32(truncatingIfNeeded: id &+ 1))
        hash = (hash ^ 61) ^ (hash >> 16)
        hash = hash &+ (hash << 3)
        hash = hash ^ (hash >> 4)
        hash = hash &* 0x27d4eb2d
        hash = hash ^ (hash >> 15)

        var hash2 = hash ^ 0xdeadbeef
        hash2 = hash2 &* 0x45d9f3b
        hash2 = (hash2 ^ (hash2 >> 16)) &* 0x119de1f3
        hash2 = hash2 ^ (hash2 >> 15)

        let lat = Double(hash % 10000) / 9999.0 * 140.0 - 60.0
        let lng = Double(hash2 % 10000) / 9999.0 * 340.0 - 170.0
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
