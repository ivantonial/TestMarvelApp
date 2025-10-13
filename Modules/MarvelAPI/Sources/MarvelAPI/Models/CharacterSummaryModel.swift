//
//  CharacterSummaryModel.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

public struct CharacterSummaryModel: Sendable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let comicsCount: Int

    public init(from character: Character) {
        self.id = character.id
        self.name = character.name
        self.imageURL = character.thumbnail.secureUrl
        self.comicsCount = character.comics.available
    }
}
