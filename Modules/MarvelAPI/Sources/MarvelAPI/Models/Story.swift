//
//  Story.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import Core

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
