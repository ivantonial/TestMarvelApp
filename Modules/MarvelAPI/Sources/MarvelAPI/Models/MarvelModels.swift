//
//  MarvelModels.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Foundation
import Core

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
public struct Character: Decodable, Identifiable, Sendable {
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
}

public struct MarvelImage: Decodable, Sendable {
    public let path: String
    public let `extension`: String

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
}

public struct ComicSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String
}

public struct SeriesList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [SeriesSummary]
    public let returned: Int
}

public struct SeriesSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String
}

public struct StoryList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [StorySummary]
    public let returned: Int
}

public struct StorySummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String
    public let type: StoryType
}

public enum StoryType: String, Decodable, UnknownCaseRepresentable, Sendable {
    case cover
    case interiorStory = "interiorStory"
    case unknown

    public static let unknownCase = Self.unknown
}

public struct EventList: Decodable, Sendable {
    public let available: Int
    public let collectionURI: String
    public let items: [EventSummary]
    public let returned: Int
}

public struct EventSummary: Decodable, Sendable {
    public let resourceURI: String
    public let name: String
}

// MARK: - Card Model
public struct CharacterCardModel: Sendable {
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

// MARK: - Hashable & Equatable
extension Character: Hashable, Equatable {
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
