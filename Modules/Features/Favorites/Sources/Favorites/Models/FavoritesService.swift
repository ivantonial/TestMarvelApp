//
//  FavoritesService.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import MarvelAPI

/// Actor para gerenciar favoritos de forma thread-safe
public actor FavoritesService {
    public static let shared = FavoritesService()

    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteCharacters"

    private init() {}

    public func getAllFavorites() async throws -> [Character] {
        let favoriteIds = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []

        return favoriteIds.compactMap { id in
            Character(
                id: id,
                name: "Character \(id)",
                description: "Description for character \(id)",
                modified: "",
                thumbnail: MarvelImage(path: "https://example.com/image", extension: "jpg"),
                resourceURI: "",
                comics: ComicList(available: Int.random(in: 10...200), collectionURI: "", items: [], returned: 0),
                series: SeriesList(available: Int.random(in: 5...50), collectionURI: "", items: [], returned: 0),
                stories: StoryList(available: 0, collectionURI: "", items: [], returned: 0),
                events: EventList(available: 0, collectionURI: "", items: [], returned: 0),
                urls: []
            )
        }
    }

    public func addFavorite(character: Character) async throws {
        var favoriteIds = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        if !favoriteIds.contains(character.id) {
            favoriteIds.append(character.id)
            userDefaults.set(favoriteIds, forKey: favoritesKey)

            // Postar notificação no MainActor
            await MainActor.run {
                NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
            }
        }
    }

    public func removeFavorite(characterId: Int) async throws {
        var favoriteIds = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        favoriteIds.removeAll { $0 == characterId }
        userDefaults.set(favoriteIds, forKey: favoritesKey)

        // Postar notificação no MainActor
        await MainActor.run {
            NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        }
    }

    public func isFavorite(characterId: Int) async -> Bool {
        let favoriteIds = userDefaults.array(forKey: favoritesKey) as? [Int] ?? []
        return favoriteIds.contains(characterId)
    }
}
