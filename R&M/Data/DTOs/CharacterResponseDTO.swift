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

struct LocationDTO: Decodable {
    let name: String
}

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationDTO
    let location: LocationDTO
    let image: String
    let episode: [String]

    func toDomain() -> Character {
        let episodeNumbers = episode.compactMap { url -> Int? in
            guard let last = url.split(separator: "/").last else { return nil }
            return Int(last)
        }
        return Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            originName: origin.name,
            locationName: location.name,
            image: URL(string: image),
            episodes: episodeNumbers
        )
    }
}
