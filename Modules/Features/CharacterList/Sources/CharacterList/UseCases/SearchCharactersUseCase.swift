//
//  SearchCharactersUseCase.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import MarvelAPI
import Cache

/// Use Case para busca de personagens com cache (versão local para CharacterList)
public final class CharacterListSearchUseCase: Sendable {
    private let service: MarvelServiceProtocol
    private let cacheManager: CacheManagerProtocol
    private let cacheKey = "character_list_search_"

    public init(service: MarvelServiceProtocol, cacheManager: CacheManagerProtocol? = nil) {
        self.service = service
        self.cacheManager = cacheManager ?? CacheManager.shared
    }

    public func execute(query: String, offset: Int = 0, limit: Int = 20) async throws -> [Character] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let cacheKey = "\(self.cacheKey)\(trimmedQuery)_\(offset)_\(limit)"

        // 1️⃣ Tenta buscar do cache
        if let cachedData = await cacheManager.load([EncodableCharacter].self, forKey: cacheKey),
           !(await cacheManager.isExpired(forKey: cacheKey)) {
            return cachedData.map {
                Character(
                    id: $0.id,
                    name: $0.name,
                    description: $0.description,
                    modified: $0.modified,
                    thumbnail: MarvelImage(path: $0.thumbnailPath, extension: $0.thumbnailExtension),
                    resourceURI: $0.resourceURI,
                    comics: ComicList(available: 0, collectionURI: "", items: [], returned: 0),
                    series: SeriesList(available: 0, collectionURI: "", items: [], returned: 0),
                    stories: StoryList(available: 0, collectionURI: "", items: [], returned: 0),
                    events: EventList(available: 0, collectionURI: "", items: [], returned: 0),
                    urls: []
                )
            }
        }

        // 2️⃣ Busca na API
        let results = try await service.searchCharacters(query: trimmedQuery, offset: offset, limit: limit)

        // 3️⃣ Salva no cache (convertendo para EncodableCharacter)
        if !results.isEmpty {
            let encodableResults = results.map(EncodableCharacter.init(from:))
            await cacheManager.save(encodableResults, forKey: cacheKey)
            await cacheManager.setExpirationDate(Date().addingTimeInterval(3600), forKey: cacheKey)
        }

        return results
    }
}
