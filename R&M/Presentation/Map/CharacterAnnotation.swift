//
//  CharacterAnnotation.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import CoreLocation

struct CharacterAnnotation: Identifiable, Hashable {
    let id: Int
    let character: Character
    let coordinate: CLLocationCoordinate2D

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: CharacterAnnotation, rhs: CharacterAnnotation) -> Bool { lhs.id == rhs.id }
}
