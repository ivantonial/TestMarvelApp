//
//  Character.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

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

    public init(
        id: Int,
        name: String,
        description: String,
        modified: String,
        thumbnail: MarvelImage,
        resourceURI: String,
        comics: ComicList,
        series: SeriesList,
        stories: StoryList,
        events: EventList,
        urls: [MarvelURL]
    ) {
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
