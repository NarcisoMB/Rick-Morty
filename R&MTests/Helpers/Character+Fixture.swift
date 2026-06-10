import Foundation
@testable import R_M

extension Character {
    static func mock(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        originName: String = "Earth (C-137)",
        locationName: String = "Citadel of Ricks",
        image: URL? = URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
        episodes: [Int] = [1, 2, 3]
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            originName: originName,
            locationName: locationName,
            image: image,
            episodes: episodes
        )
    }
}

extension CharacterPage {
    static func mock(
        characters: [Character] = [.mock()],
        hasNextPage: Bool = true,
        totalPages: Int = 42
    ) -> CharacterPage {
        CharacterPage(characters: characters, hasNextPage: hasNextPage, totalPages: totalPages)
    }
}
