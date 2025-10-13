//
//  ComicCardModel.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import Foundation
import MarvelAPI
import DesignSystem

public struct ComicCardModel: Identifiable {
    public let id: Int
    public let title: String
    public let description: String?
    public let imageURL: URL?

    public init(id: Int, title: String, description: String?, imageURL: URL?) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
    }

    public init(from comic: Comic) {
        self.id = comic.id
        self.title = comic.title
        self.description = comic.description
        self.imageURL = comic.thumbnail.secureUrl
    }

    func toContentCardModel() -> ContentCardModel {
        ContentCardModel(
            id: id,
            title: title,
            subtitle: description,
            imageURL: imageURL,
            aspectRatio: 0.77, // Proporção de HQ (mais alta)
            badge: nil // Comics não precisam de badge
        )
    }
}
