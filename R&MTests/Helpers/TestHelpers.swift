import CoreData
@testable import R_M

// Synchronously inserts characters into a CoreData context for test setup.
func insertCharacters(_ characters: [Character], page: Int, into context: NSManagedObjectContext) throws {
    for character in characters {
        let entity = CharacterEntity(context: context)
        entity.id           = Int32(character.id)
        entity.name         = character.name
        entity.status       = character.status
        entity.species      = character.species
        entity.type         = character.type
        entity.gender       = character.gender
        entity.originName   = character.originName
        entity.locationName = character.locationName
        entity.imageURL     = character.image?.absoluteString
        entity.episodesRaw  = character.episodes.map(String.init).joined(separator: ",")
        entity.page         = Int32(page)
    }
    try context.save()
}

func makeResponseData(characters: [Character], hasNextPage: Bool, totalPages: Int) -> Data {
    let results = characters.map { char -> [String: Any] in
        [
            "id": char.id,
            "name": char.name,
            "status": char.status,
            "species": char.species,
            "type": char.type,
            "gender": char.gender,
            "origin": ["name": char.originName],
            "location": ["name": char.locationName],
            "image": char.image?.absoluteString ?? "",
            "episode": char.episodes.map { "https://rickandmortyapi.com/api/episode/\($0)" }
        ]
    }
    let payload: [String: Any] = [
        "info": ["next": hasNextPage ? "https://rickandmortyapi.com/api/character?page=2" : NSNull(), "pages": totalPages],
        "results": results
    ]
    return try! JSONSerialization.data(withJSONObject: payload)
}
