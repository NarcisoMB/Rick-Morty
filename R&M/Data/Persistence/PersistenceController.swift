//
//  PersistenceController.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import CoreData

final class PersistenceController {
	static let shared = PersistenceController()
	
	let container: NSPersistentContainer
	
	init(inMemory: Bool = false) {
		self.container = NSPersistentContainer(name: "RickAndMorty", managedObjectModel: Self.model)
		if inMemory {
			self.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}
		self.container.loadPersistentStores { [weak container] desc, error in
			guard error != nil else { return }
			if let url = desc.url {
				try? FileManager.default.removeItem(at: url)
			}
			container?.loadPersistentStores { _, error in
				if let error { fatalError("CoreData store failed after reset: \(error)") }
			}
		}
		self.container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	static let preview = PersistenceController(inMemory: true)
	
	private static let model: NSManagedObjectModel = {
		let entity = NSEntityDescription()
		entity.name = "CharacterEntity"
		entity.managedObjectClassName = NSStringFromClass(CharacterEntity.self)
		
		func attr(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
			let desc = NSAttributeDescription()
			desc.name = name
			desc.attributeType = type
			desc.isOptional = true
			return desc
		}
		
		entity.properties = [
			attr("id", .integer32AttributeType),
			attr("name", .stringAttributeType),
			attr("status", .stringAttributeType),
			attr("species", .stringAttributeType),
			attr("type", .stringAttributeType),
			attr("gender", .stringAttributeType),
			attr("originName", .stringAttributeType),
			attr("locationName", .stringAttributeType),
			attr("imageURL", .stringAttributeType),
			attr("episodesRaw", .stringAttributeType),
			attr("page", .integer32AttributeType)
		]
		
		let model = NSManagedObjectModel()
		model.entities = [entity]
		return model
	}()
}
