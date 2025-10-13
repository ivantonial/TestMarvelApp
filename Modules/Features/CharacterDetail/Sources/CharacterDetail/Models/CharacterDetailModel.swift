//
//  CharacterDetailModel.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import DesignSystem
import Foundation
import MarvelAPI
import SwiftUI

// MARK: - Main Detail Model
public struct CharacterDetailModel: Sendable {
    public let character: Character
    public let stats: CharacterStatsModel
    public let relatedContent: CharacterRelatedContentModel
    public let shareInfo: CharacterShareInfoModel

    public init(from character: Character) {
        self.character = character
        self.stats = CharacterStatsModel(from: character)
        self.relatedContent = CharacterRelatedContentModel(from: character)
        self.shareInfo = CharacterShareInfoModel(from: character)
    }

    public mutating func update(with character: Character) {
        self = CharacterDetailModel(from: character)
    }
}

// MARK: - Stats Model
public struct CharacterStatsModel: Sendable {
    public let comics: StatItemModel
    public let series: StatItemModel
    public let stories: StatItemModel
    public let events: StatItemModel

    init(from character: Character) {
        self.comics = StatItemModel(
            icon: "book.fill",
            title: "Comics",
            value: character.comics.available,
            color: .red
        )
        self.series = StatItemModel(
            icon: "tv.fill",
            title: "Series",
            value: character.series.available,
            color: .blue
        )
        self.stories = StatItemModel(
            icon: "star.fill",
            title: "Stories",
            value: character.stories.available,
            color: .yellow
        )
        self.events = StatItemModel(
            icon: "calendar",
            title: "Events",
            value: character.events.available,
            color: .green
        )
    }

    public var allStats: [StatItemModel] {
        [comics, series, stories, events]
    }
}

// MARK: - Stat Item Model
public struct StatItemModel: Sendable, Identifiable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let value: Int
    public let color: ColorType

    public var displayValue: String {
        "\(value)"
    }
}

// MARK: - Related Content Model
public struct CharacterRelatedContentModel: Sendable {
    public let recentComics: [RelatedItemModel]
    public let recentSeries: [RelatedItemModel]

    init(from character: Character) {
        self.recentComics = character.comics.items.prefix(5).map { comic in
            RelatedItemModel(
                name: comic.name,
                resourceURI: comic.resourceURI,
                type: .comic
            )
        }

        self.recentSeries = character.series.items.prefix(5).map { series in
            RelatedItemModel(
                name: series.name,
                resourceURI: series.resourceURI,
                type: .series
            )
        }
    }

    public var hasContent: Bool {
        !recentComics.isEmpty || !recentSeries.isEmpty
    }
}

// MARK: - Related Item Model
public struct RelatedItemModel: Sendable, Identifiable {
    public var id: String { resourceURI }
    public let name: String
    public let resourceURI: String
    public let type: RelatedItemType

    public enum RelatedItemType: Sendable {
        case comic
        case series

        public var icon: String {
            switch self {
            case .comic: return "book.circle.fill"
            case .series: return "tv.circle.fill"
            }
        }

        public var color: DesignSystem.ColorType {
            switch self {
            case .comic: return .red
            case .series: return .blue
            }
        }
    }
}

// MARK: - Share Info Model
public struct CharacterShareInfoModel: Sendable {
    public let text: String
    public let detailURL: URL?
    public let wikiURL: URL?
    public let imageURL: URL?

    init(from character: Character) {
        self.text = "Check out \(character.name) on Marvel!"
        self.detailURL = character.urls.first(where: { $0.type == .detail })
            .flatMap { URL(string: $0.url) }
        self.wikiURL = character.urls.first(where: { $0.type == .wiki })
            .flatMap { URL(string: $0.url) }
        self.imageURL = character.thumbnail.secureUrl
    }

    public var shareItems: [Any] {
        var items: [Any] = [text]
        if let detailURL = detailURL {
            items.append(detailURL)
        }
        if let imageURL = imageURL {
            items.append(imageURL)
        }
        return items
    }
}
