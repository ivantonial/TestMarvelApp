//
//  Comic.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

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
