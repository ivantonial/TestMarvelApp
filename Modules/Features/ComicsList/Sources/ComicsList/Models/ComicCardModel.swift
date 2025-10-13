import DesignSystem
//
//  ComicCardModel.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import Foundation
import MarvelAPI
import SwiftUI

public struct ComicCardModel: Identifiable, ContentCardConvertible {
    public let id: Int
    public let title: String
    public let description: String?
    public let marvelImage: MarvelImage?
    public let aspectRatio: CGFloat

    public init(id: Int, title: String, description: String?, marvelImage: MarvelImage?, aspectRatio: CGFloat = 0.75) {
        self.id = id
        self.title = title
        self.description = description
        self.marvelImage = marvelImage
        self.aspectRatio = aspectRatio
    }

    public init(from comic: Comic) {
        self.id = comic.id
        self.title = comic.title
        self.description = comic.description
        self.marvelImage = comic.thumbnail
        self.aspectRatio = 0.75
    }

    // MARK: - Conversão para ContentCardModel
    public func toContentCardModel() -> ContentCardModel {
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
