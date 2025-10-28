//
//  ComicCardModel.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import DesignSystem
import Foundation
import MarvelAPI
import SwiftUI

public struct ComicCardModel: Identifiable, ContentCardConvertible {
    public let id: Int
    public let title: String
    public let description: String?
    public let marvelImage: MarvelImage?
    public let aspectRatio: CGFloat

    // Aspecto padrão para comics é portrait (2:3)
    private static let defaultComicAspectRatio: CGFloat = 0.67  // 2:3 ratio

    public init(
        id: Int,
        title: String,
        description: String?,
        marvelImage: MarvelImage?,
        aspectRatio: CGFloat? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.marvelImage = marvelImage
        // Usa o aspect ratio fornecido ou o padrão para comics
        self.aspectRatio = aspectRatio ?? Self.defaultComicAspectRatio
    }

    public init(from comic: Comic) {
        self.id = comic.id
        self.title = comic.title
        self.description = comic.description
        self.marvelImage = comic.thumbnail
        // Comics sempre usam o aspect ratio padrão portrait
        self.aspectRatio = Self.defaultComicAspectRatio
    }

    // MARK: - Conversão para ContentCardModel
    public func toContentCardModel() -> ContentCardModel {
        // Para comics (aspect ratio menor que 0.9), usa .fit para manter proporção
        let mode: ContentMode = aspectRatio < 0.9 ? .fit : .fill

        return ContentCardModel(
            id: id,
            title: title,
            subtitle: description?.isEmpty == false ? description : nil,
            marvelImage: marvelImage,
            aspectRatio: aspectRatio,
            contentMode: mode,
            badge: defaultBadge(icon: "book.pages.fill", text: "HQ")
        )
    }
}
