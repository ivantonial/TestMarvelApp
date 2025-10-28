//
//  EncodableCompat.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import MarvelAPI

// MARK: - Codable Wrappers para cache seguro sem modificar as models originais

public struct EncodableCharacter: Codable, Sendable {
    public let id: Int
    public let name: String
    public let description: String
    public let modified: String
    public let thumbnailPath: String
    public let thumbnailExtension: String
    public let resourceURI: String
    public let comicsAvailable: Int
    public let seriesAvailable: Int
    public let storiesAvailable: Int
    public let eventsAvailable: Int

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.description = character.description
        self.modified = character.modified
        self.thumbnailPath = character.thumbnail.path
        self.thumbnailExtension = character.thumbnail.extension
        self.resourceURI = character.resourceURI
        self.comicsAvailable = character.comics.available
        self.seriesAvailable = character.series.available
        self.storiesAvailable = character.stories.available
        self.eventsAvailable = character.events.available
    }

    // MARK: - Custom Encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(modified, forKey: .modified)
        try container.encode(thumbnailPath, forKey: .thumbnailPath)
        try container.encode(thumbnailExtension, forKey: .thumbnailExtension)
        try container.encode(resourceURI, forKey: .resourceURI)
        try container.encode(comicsAvailable, forKey: .comicsAvailable)
        try container.encode(seriesAvailable, forKey: .seriesAvailable)
        try container.encode(storiesAvailable, forKey: .storiesAvailable)
        try container.encode(eventsAvailable, forKey: .eventsAvailable)
    }

    // MARK: - Custom Decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        modified = try container.decode(String.self, forKey: .modified)
        thumbnailPath = try container.decode(String.self, forKey: .thumbnailPath)
        thumbnailExtension = try container.decode(String.self, forKey: .thumbnailExtension)
        resourceURI = try container.decode(String.self, forKey: .resourceURI)
        comicsAvailable = try container.decodeIfPresent(Int.self, forKey: .comicsAvailable) ?? 0
        seriesAvailable = try container.decodeIfPresent(Int.self, forKey: .seriesAvailable) ?? 0
        storiesAvailable = try container.decodeIfPresent(Int.self, forKey: .storiesAvailable) ?? 0
        eventsAvailable = try container.decodeIfPresent(Int.self, forKey: .eventsAvailable) ?? 0
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, description, modified, thumbnailPath, thumbnailExtension, resourceURI, comicsAvailable, seriesAvailable, storiesAvailable, eventsAvailable
    }
}

public struct EncodableComic: Codable, Sendable {
    public let id: Int
    public let title: String
    public let description: String?
    public let thumbnailPath: String
    public let thumbnailExtension: String

    public init(from comic: Comic) {
        self.id = comic.id
        self.title = comic.title
        self.description = comic.description
        self.thumbnailPath = comic.thumbnail.path
        self.thumbnailExtension = comic.thumbnail.extension
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(thumbnailPath, forKey: .thumbnailPath)
        try container.encode(thumbnailExtension, forKey: .thumbnailExtension)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        thumbnailPath = try container.decode(String.self, forKey: .thumbnailPath)
        thumbnailExtension = try container.decode(String.self, forKey: .thumbnailExtension)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, description, thumbnailPath, thumbnailExtension
    }
}
