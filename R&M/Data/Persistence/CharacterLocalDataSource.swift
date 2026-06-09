//
//  CharacterLocalDataSource.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import CoreData

struct CharacterLocalDataSource {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func fetchCharacters(page: Int) -> [Character] {
		let context = self.container.viewContext
        let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
        request.predicate = NSPredicate(format: "page == %d", Int32(page))
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return (try? context.fetch(request))?.map { $0.toDomain() } ?? []
    }

    func save(characters: [Character], page: Int) {
		let context = self.container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
            request.predicate = NSPredicate(format: "page == %d", Int32(page))
            let existing = (try? context.fetch(request)) ?? []
            let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

            for character in characters {
                let entity = existingById[Int32(character.id)] ?? CharacterEntity(context: context)
                entity.id           = Int32(character.id)
                entity.name         = character.name
                entity.status       = character.status
                entity.species      = character.species
                entity.type         = character.type
                entity.gender       = character.gender
                entity.originName   = character.originName
                entity.locationName = character.locationName
                entity.imageURL     = character.image?.absoluteString
                entity.episodeCount = Int32(character.episodeCount)
                entity.page         = Int32(page)
            }

            try? context.save()
        }
    }
}
