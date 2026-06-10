//
//  CharacterEntity.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import CoreData

@objc(CharacterEntity)
final class CharacterEntity: NSManagedObject {
    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var status: String?
    @NSManaged var species: String?
    @NSManaged var type: String?
    @NSManaged var gender: String?
    @NSManaged var originName: String?
    @NSManaged var locationName: String?
    @NSManaged var imageURL: String?
    @NSManaged var episodesRaw: String?
    @NSManaged var page: Int32

    func toDomain() -> Character {
        let episodes = episodesRaw?
            .split(separator: ",")
            .compactMap { Int($0) } ?? []
        return Character(
            id: Int(id),
            name: name ?? "",
            status: status ?? "",
            species: species ?? "",
            type: type ?? "",
            gender: gender ?? "",
            originName: originName ?? "",
            locationName: locationName ?? "",
            image: imageURL.flatMap(URL.init),
            episodes: episodes
        )
    }
}
