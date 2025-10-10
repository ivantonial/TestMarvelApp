//
//  CoreDataStack.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import CoreData
import Foundation
import MarvelAPI

public final class CoreDataStack: @unchecked Sendable {
    public static let shared = CoreDataStack()

    private let modelName = "MarvelCache"

    lazy var persistentContainer: NSPersistentContainer = {
        let model = createModel()
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        description?.type = NSSQLiteStoreType
        description?.setOption(["journal_mode": "WAL"] as NSDictionary, forKey: NSSQLitePragmasOption)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data stack: \(error)")
            }
        }

        let mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = mergePolicy
        return container
    }()

    public var mainContext: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {}

    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }

    public func save(context: NSManagedObjectContext? = nil) {
        let context = context ?? mainContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("⚠️ Failed to save Core Data context: \(error)")
        }
    }

    public func clearAllData() {
        let entities = persistentContainer.managedObjectModel.entities
        entities.forEach { entity in
            guard let entityName = entity.name else { return }
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            do {
                try mainContext.execute(delete)
                try mainContext.save()
            } catch {
                print("⚠️ Failed to clear \(entityName): \(error)")
            }
        }
    }

    private func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            CDCharacter.entityDescription(),
            CDComic.entityDescription(),
            CDSearchHistory.entityDescription()
        ]
        return model
    }
}

// MARK: - Helper seguro e inequívoco
extension CoreDataStack {
    static func cdMakeAttribute(
        name: String,
        type: NSAttributeType,
        optional: Bool = true
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = optional
        return attr
    }
}
