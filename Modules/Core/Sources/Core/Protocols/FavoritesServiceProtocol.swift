//
//  FavoritesServiceProtocol.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import MarvelAPI

public protocol FavoritesServiceProtocol: Sendable {
    func isFavorite(characterId: Int) async -> Bool
    func addFavorite(character: Character) async throws
    func removeFavorite(characterId: Int) async throws
    func getAllFavorites() async throws -> [Character]
}
