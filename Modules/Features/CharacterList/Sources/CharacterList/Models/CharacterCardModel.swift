//
//  CharacterCardModel.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

//import Foundation
//import MarvelAPI
//
//public struct CharacterCardModel: Identifiable {
//    public let id: Int
//    public let name: String
//    public let imageURL: URL?
//    public let comicsCount: Int
//
//    public init(id: Int, name: String, imageURL: URL?, comicsCount: Int) {
//        self.id = id
//        self.name = name
//        self.imageURL = imageURL
//        self.comicsCount = comicsCount
//    }
//
//    public init(from character: Character) {
//        self.id = character.id
//        self.name = character.name
//        self.imageURL = character.thumbnail.secureUrl
//        self.comicsCount = character.comics.available
//    }
//}
//import Foundation
//import MarvelAPI
//
///// Modelo de exibição simplificado para o card de personagem
//public struct CharacterCardModel: Identifiable {
//    public let id: Int
//    public let name: String
//    public let marvelImage: MarvelImage?
//    public let comicsCount: Int
//
//    public init(id: Int, name: String, marvelImage: MarvelImage?, comicsCount: Int) {
//        self.id = id
//        self.name = name
//        self.marvelImage = marvelImage
//        self.comicsCount = comicsCount
//    }
//
//    public init(from character: Character) {
//        self.id = character.id
//        self.name = character.name
//        self.marvelImage = character.thumbnail // 🔁 agora usa MarvelImage diretamente
//        self.comicsCount = character.comics.available
//    }
//}
//import Foundation
//import MarvelAPI
//
///// Modelo de exibição simplificado para o card de personagem
//public struct CharacterCardModel: Identifiable {
//    public let id: Int
//    public let name: String
//    public let marvelImage: MarvelImage?
//    public let comicsCount: Int
//    public let aspectRatio: CGFloat
//
//    public init(id: Int, name: String, marvelImage: MarvelImage?, comicsCount: Int, aspectRatio: CGFloat) {
//        self.id = id
//        self.name = name
//        self.marvelImage = marvelImage
//        self.comicsCount = comicsCount
//        self.aspectRatio = aspectRatio
//    }
//
//    public init(from character: Character) {
//        self.id = character.id
//        self.name = character.name
//        self.marvelImage = character.thumbnail
//        self.comicsCount = character.comics.available
//
//        // Ajusta proporção dinamicamente
//        if character.thumbnail.path.contains("image_not_available") {
//            self.aspectRatio = 1.0 // força quadrado para placeholders
//        } else {
//            self.aspectRatio = 1.0 // heróis normais (quadrados)
//        }
//    }
//
//}
import Foundation
import MarvelAPI
import DesignSystem
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
