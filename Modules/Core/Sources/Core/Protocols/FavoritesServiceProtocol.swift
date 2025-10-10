//
//  FavoritesServiceProtocol.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public struct FavoriteCharacterInput: Sendable {
    public let id: Int
    public let name: String
    public let thumbnailURL: URL?

    public init(id: Int, name: String, thumbnailURL: URL?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
    }
}

public protocol FavoritesServiceProtocol: Sendable {
    func isFavorite(characterId: Int) async -> Bool
    func addFavorite(character: FavoriteCharacterInput) async throws
    func removeFavorite(characterId: Int) async throws
}
