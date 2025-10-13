//
//  CDCharacter.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import CoreData
import Foundation
import MarvelAPI

@objc(CDCharacter)
public class CDCharacter: NSManagedObject {
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var characterDescription: String?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var comicsCount: Int32
    @NSManaged public var seriesCount: Int32
    @NSManaged public var storiesCount: Int32
    @NSManaged public var eventsCount: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var cachedAt: Date?

    func toCharacter() -> MarvelAPI.Character? {
        guard let name = name else { return nil }

        let thumbnail = MarvelAPI.MarvelImage(path: thumbnailPath ?? "", extension: "jpg")

        return MarvelAPI.Character(
            id: Int(id),
            name: name,
            description: characterDescription ?? "",
            modified: "",
            thumbnail: thumbnail,
            resourceURI: "",
            comics: MarvelAPI.ComicList(available: Int(comicsCount), collectionURI: "", items: [], returned: 0),
            series: MarvelAPI.SeriesList(available: Int(seriesCount), collectionURI: "", items: [], returned: 0),
            stories: MarvelAPI.StoryList(available: Int(storiesCount), collectionURI: "", items: [], returned: 0),
            events: MarvelAPI.EventList(available: Int(eventsCount), collectionURI: "", items: [], returned: 0),
            urls: []
        )
    }

    func update(from character: MarvelAPI.Character) {
        id = Int32(character.id)
        name = character.name
        characterDescription = character.description
        thumbnailPath = character.thumbnail.path
        comicsCount = Int32(character.comics.available)
        seriesCount = Int32(character.series.available)
        storiesCount = Int32(character.stories.available)
        eventsCount = Int32(character.events.available)
        lastUpdated = Date()
        cachedAt = Date()
    }
}

extension CDCharacter {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDCharacter> {
        NSFetchRequest<CDCharacter>(entityName: "CDCharacter")
    }

    static func entityDescription() -> NSEntityDescription {
        let e = NSEntityDescription()
        e.name = "CDCharacter"
        e.managedObjectClassName = NSStringFromClass(CDCharacter.self)
        e.properties = [
            CoreDataStack.cdMakeAttribute(name: "id", type: .integer32AttributeType, optional: false),
            CoreDataStack.cdMakeAttribute(name: "name", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "characterDescription", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "thumbnailPath", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "comicsCount", type: .integer32AttributeType),
            CoreDataStack.cdMakeAttribute(name: "seriesCount", type: .integer32AttributeType),
            CoreDataStack.cdMakeAttribute(name: "storiesCount", type: .integer32AttributeType),
            CoreDataStack.cdMakeAttribute(name: "eventsCount", type: .integer32AttributeType),
            CoreDataStack.cdMakeAttribute(name: "isFavorite", type: .booleanAttributeType),
            CoreDataStack.cdMakeAttribute(name: "lastUpdated", type: .dateAttributeType),
            CoreDataStack.cdMakeAttribute(name: "cachedAt", type: .dateAttributeType)
        ]
        return e
    }
}
