//
//  CDComic.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import CoreData
import Foundation
import MarvelAPI

@objc(CDComic)
public class CDComic: NSManagedObject {
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var comicDescription: String?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var characterId: Int32
    @NSManaged public var cachedAt: Date?

    func toComic() -> Comic? {
        guard let title = title else { return nil }
        let thumb = MarvelImage(path: thumbnailPath ?? "", extension: "jpg")
        return Comic(id: Int(id), title: title, description: comicDescription, thumbnail: thumb)
    }

    func update(from comic: Comic, characterId: Int) {
        id = Int32(comic.id)
        title = comic.title
        comicDescription = comic.description
        thumbnailPath = comic.thumbnail.path
        self.characterId = Int32(characterId)
        cachedAt = Date()
    }
}

extension CDComic {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDComic> {
        NSFetchRequest<CDComic>(entityName: "CDComic")
    }

    static func entityDescription() -> NSEntityDescription {
        let e = NSEntityDescription()
        e.name = "CDComic"
        e.managedObjectClassName = NSStringFromClass(CDComic.self)
        e.properties = [
            CoreDataStack.cdMakeAttribute(name: "id", type: .integer32AttributeType, optional: false),
            CoreDataStack.cdMakeAttribute(name: "title", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "comicDescription", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "thumbnailPath", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "characterId", type: .integer32AttributeType),
            CoreDataStack.cdMakeAttribute(name: "cachedAt", type: .dateAttributeType)
        ]
        return e
    }
}
