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

    private let store = CharacterStore.shared
    private let useCase: GetCharactersUseCase

    init(useCase: GetCharactersUseCase = GetCharactersUseCase(repository: CharacterRepository())) {
        self.useCase = useCase
    }

    var annotations: [CharacterAnnotation] {
        store.characters.map {
            CharacterAnnotation(id: $0.id, character: $0, coordinate: Self.coordinate(for: $0.id))
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
        var h = UInt32(bitPattern: Int32(truncatingIfNeeded: id &+ 1))
        h = (h ^ 61) ^ (h >> 16)
        h = h &+ (h << 3)
        h = h ^ (h >> 4)
        h = h &* 0x27d4eb2d
        h = h ^ (h >> 15)

        var h2 = h ^ 0xdeadbeef
        h2 = h2 &* 0x45d9f3b
        h2 = (h2 ^ (h2 >> 16)) &* 0x119de1f3
        h2 = h2 ^ (h2 >> 15)

        let lat = Double(h % 10000) / 9999.0 * 140.0 - 60.0
        let lng = Double(h2 % 10000) / 9999.0 * 340.0 - 170.0
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
