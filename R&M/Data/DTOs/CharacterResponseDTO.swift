//
//  CharacterResponseDTO.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import Foundation

struct CharacterResponseDTO: Decodable {
    let info: InfoDTO
    let results: [CharacterDTO]
}

struct InfoDTO: Decodable {
    let next: String?
    let pages: Int
}

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String

    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            image: URL(string: image)
        )
    }
}
