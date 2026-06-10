//
//  EpisodeDTO.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

struct EpisodeDTO: Decodable {
    let id: Int
    let name: String
    let episode: String

    func toDomain() -> Episode {
        Episode(id: id, name: name, code: episode)
    }
}

// The API returns a plain object for 1 ID and an array for multiple.
struct EpisodeResponseDTO: Decodable {
    let items: [EpisodeDTO]

    init(from decoder: Decoder) throws {
        if let array = try? [EpisodeDTO](from: decoder) {
            items = array
        } else {
            items = [try EpisodeDTO(from: decoder)]
        }
    }
}
