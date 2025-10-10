//
//  MarvelModels.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Core
import Foundation

// MARK: - Response Wrapper
public struct MarvelResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let code: Int
    public let status: String
    public let copyright: String?
    public let attributionText: String?
    public let attributionHTML: String?
    public let etag: String?
    public let data: MarvelDataContainer<T>
}

public struct MarvelDataContainer<T: Decodable & Sendable>: Decodable, Sendable {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let count: Int
    public let results: [T]
}

// MARK: - Character Models
public struct Character: Decodable, Identifiable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let description: String
    public let modified: String
    public let thumbnail: MarvelImage
    public let resourceURI: String
    public let comics: ComicList
    public let series: SeriesList
    public let stories: StoryList
    public let events: EventList
    public let urls: [MarvelURL]

    public init(id: Int, name: String, description: String, modified: String, thumbnail: MarvelImage, resourceURI: String, comics: ComicList, series: SeriesList, stories: StoryList, events: EventList, urls: [MarvelURL]) {
        self.id = id
        self.name = name
        self.description = description
        self.modified = modified
        self.thumbnail = thumbnail
        self.resourceURI = resourceURI
        self.comics = comics
        self.series = series
        self.stories = stories
        self.events = events
        self.urls = urls
    }

    public static func == (lhs: Character, rhs: Character) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

public struct MarvelImage: Decodable, Sendable {
    public let path: String
    public let `extension`: String

    public init(path: String, extension: String) {
        self.path = path
        self.`extension` = `extension`
    }

    public var url: URL? {
        URL(string: "\(path).\(`extension`)")
    }

    public var secureUrl: URL? {
        let securePath = path.replacingOccurrences(of: "http://", with: "https://")
        return URL(string: "\(securePath).\(`extension`)")
    }
}

public struct MarvelURL: Decodable, Sendable {
    public let type: URLType
    public let url: String
}

public enum URLType: String, Decodable, UnknownCaseRepresentable, Sendable {
    case detail
    case wiki
    case comiclink
    case unknown

    public static let unknownCase = Self.unknown
}

// MARK: - Related Lists
public struct ComicList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [ComicSummary]
    public let returned: Int

    public init(available: Int, collectionURI: String, items: [ComicSummary], returned: Int) {
        self.available = available
        self.collectionURI = collectionURI
        self.items = items
        self.returned = returned
    }
}

public struct ComicSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }
}

public struct SeriesList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [SeriesSummary]
    public let returned: Int

    public init(available: Int, collectionURI: String, items: [SeriesSummary], returned: Int) {
        self.available = available
        self.collectionURI = collectionURI
        self.items = items
        self.returned = returned
    }
}

public struct SeriesSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }
}

public struct StoryList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [StorySummary]
    public let returned: Int

    public init(available: Int, collectionURI: String, items: [StorySummary], returned: Int) {
        self.available = available
        self.collectionURI = collectionURI
        self.items = items
        self.returned = returned
    }
}

public struct StorySummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String
    public let type: StoryType

    public init(resourceURI: String, name: String, type: StoryType) {
        self.resourceURI = resourceURI
        self.name = name
        self.type = type
    }
}

public enum StoryType: String, Decodable, UnknownCaseRepresentable, Sendable {
    case cover
    case interiorStory
    case unknown

    public static let unknownCase = Self.unknown
}

public struct EventList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [EventSummary]
    public let returned: Int

    public init(available: Int, collectionURI: String, items: [EventSummary], returned: Int) {
        self.available = available
        self.collectionURI = collectionURI
        self.items = items
        self.returned = returned
    }
}

public struct EventSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }
}

// MARK: - Comic Models
public struct Comic: Decodable, Identifiable, Sendable, Hashable {
    public let id: Int
    public let title: String
    public let description: String?
    public let thumbnail: MarvelImage

    public init(id: Int, title: String, description: String?, thumbnail: MarvelImage) {
        self.id = id
        self.title = title
        self.description = description
        self.thumbnail = thumbnail
    }

    public static func == (lhs: Comic, rhs: Comic) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - (Opcional) Resumo de domínio, sem semântica de UI
public struct CharacterSummaryModel: Sendable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let comicsCount: Int

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.imageURL = character.thumbnail.secureUrl
        self.comicsCount = character.comics.available
    }
}
