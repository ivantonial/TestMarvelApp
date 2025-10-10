//
//  CharacterCardModel.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import MarvelAPI

public struct CharacterCardModel: Identifiable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let comicsCount: Int

    public init(id: Int, name: String, imageURL: URL?, comicsCount: Int) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.comicsCount = comicsCount
    }

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.imageURL = character.thumbnail.secureUrl
        self.comicsCount = character.comics.available
    }
}
