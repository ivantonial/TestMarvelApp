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

    // Aspecto padrão para personagens é quadrado (1:1)
    private static let defaultCharacterAspectRatio: CGFloat = 1.0

    public init(
        id: Int,
        name: String,
        marvelImage: MarvelImage?,
        comicsCount: Int,
        aspectRatio: CGFloat? = nil
    ) {
        self.id = id
        self.name = name
        self.marvelImage = marvelImage
        self.comicsCount = comicsCount
        // Usa o aspect ratio fornecido ou o padrão para personagens
        self.aspectRatio = aspectRatio ?? Self.defaultCharacterAspectRatio
    }

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.marvelImage = character.thumbnail
        self.comicsCount = character.comics.available
        // Personagens sempre usam o aspect ratio padrão quadrado
        self.aspectRatio = Self.defaultCharacterAspectRatio
    }

    // MARK: - Conversão para ContentCardModel
    public func toContentCardModel() -> ContentCardModel {
        // Para personagens (aspect ratio próximo de 1.0), usa .fill para preencher
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
