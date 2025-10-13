//
//  CharacterCardModel.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import DesignSystem
import Foundation
import MarvelAPI
import SwiftUI

public struct CharacterCardModel: Identifiable, ContentCardConvertible {
    public let id: Int
    public let name: String
    public let marvelImage: MarvelImage?
    public let comicsCount: Int
    public let aspectRatio: CGFloat

    public init(id: Int, name: String, marvelImage: MarvelImage?, comicsCount: Int, aspectRatio: CGFloat = 1.0) {
        self.id = id
        self.name = name
        self.marvelImage = marvelImage
        self.comicsCount = comicsCount
        self.aspectRatio = aspectRatio
    }

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.marvelImage = character.thumbnail
        self.comicsCount = character.comics.available
        self.aspectRatio = 1.0
    }

    // MARK: - Conversão para ContentCardModel
    public func toContentCardModel() -> ContentCardModel {
        let mode: ContentMode = aspectRatio < 0.9 ? .fit : .fill
        return ContentCardModel(
            id: id,
            title: name,
            subtitle: nil,
            marvelImage: marvelImage,
            aspectRatio: aspectRatio,
            contentMode: mode,
            badge: defaultBadge(icon: "book.fill", text: "\(comicsCount) comics")
        )
    }
}
