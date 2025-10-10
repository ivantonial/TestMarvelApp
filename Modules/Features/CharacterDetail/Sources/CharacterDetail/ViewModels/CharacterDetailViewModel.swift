//
//  CharacterDetailViewModel.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class CharacterDetailViewModel: ObservableObject {
    @Published public var character: MarvelAPI.Character
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var isFavorite = false
    @Published public var recentComics: [ComicSummary] = []
    @Published public var recentSeries: [SeriesSummary] = []
    @Published public var relatedCharacters: [MarvelAPI.Character] = []
    @Published public var comicsCount = 0
    @Published public var seriesCount = 0
    @Published public var storiesCount = 0
    @Published public var eventsCount = 0

    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase?
    private let fetchCharacterComicsUseCase: FetchCharacterComicsUseCase?
    private let favoritesService: FavoritesServiceProtocol?

    public var hasRelatedContent: Bool {
        !recentComics.isEmpty || !recentSeries.isEmpty
    }
    public var wikiURL: URL? {
        character.urls.first(where: { $0.type == .wiki }).flatMap { URL(string: $0.url) }
    }
    public var detailURL: URL? {
        character.urls.first(where: { $0.type == .detail }).flatMap { URL(string: $0.url) }
    }
    public var hasComics: Bool { character.comics.available > 0 }
    public var hasSeries: Bool { character.series.available > 0 }
    public var shareText: String { "Check out \(character.name) on Marvel! \(detailURL?.absoluteString ?? "")" }

    public init(
        character: MarvelAPI.Character,
        fetchCharacterDetailUseCase: FetchCharacterDetailUseCase? = nil,
        fetchCharacterComicsUseCase: FetchCharacterComicsUseCase? = nil,
        favoritesService: FavoritesServiceProtocol? = nil
    ) {
        self.character = character
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
        self.fetchCharacterComicsUseCase = fetchCharacterComicsUseCase
        self.favoritesService = favoritesService
        loadInitialData()
    }

    public func loadCharacterDetails() {
        guard fetchCharacterDetailUseCase != nil else {
            extractRelatedContent()
            return
        }
        Task { await fetchFullCharacterDetails() }
    }

    public func toggleFavorite() {
        Task { await toggleFavoriteAsync() }
    }

    private func toggleFavoriteAsync() async {
        isFavorite.toggle()
        await saveFavoriteStatus()
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }

    public func shareCharacter() -> [Any] {
        var items: [Any] = [shareText]
        if let url = detailURL { items.append(url) }
        if let imageURL = character.thumbnail.secureUrl { items.append(imageURL) }
        return items
    }

    public func refresh() {
        Task { await fetchFullCharacterDetails() }
    }

    private func loadInitialData() {
        extractRelatedContent()
        updateStatsCounts()
        Task { await loadFavoriteStatus() }
    }

    private func extractRelatedContent() {
        recentComics = Array(character.comics.items.prefix(5))
        recentSeries = Array(character.series.items.prefix(5))
    }

    private func updateStatsCounts() {
        comicsCount = character.comics.available
        seriesCount = character.series.available
        storiesCount = character.stories.available
        eventsCount = character.events.available
    }

    private func fetchFullCharacterDetails() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            if let useCase = fetchCharacterDetailUseCase {
                let updatedCharacter = try await useCase.execute(characterId: character.id)
                character = updatedCharacter
                extractRelatedContent()
                updateStatsCounts()
            }
            if let comicsUseCase = fetchCharacterComicsUseCase {
                _ = try await comicsUseCase.execute(characterId: character.id, limit: 10)
            }
        } catch {
            self.error = error
            print("❌ Erro ao carregar detalhes: \(error)")
        }
    }

    private func loadFavoriteStatus() async {
        guard let service = favoritesService else {
            let favorites = UserDefaults.standard.array(forKey: "FavoriteCharacters") as? [Int] ?? []
            isFavorite = favorites.contains(character.id)
            return
        }
        isFavorite = await service.isFavorite(characterId: character.id)
    }

    private func saveFavoriteStatus() async {
        guard let service = favoritesService else {
            var favorites = UserDefaults.standard.array(forKey: "FavoriteCharacters") as? [Int] ?? []
            if isFavorite {
                if !favorites.contains(character.id) { favorites.append(character.id) }
            } else {
                favorites.removeAll { $0 == character.id }
            }
            UserDefaults.standard.set(favorites, forKey: "FavoriteCharacters")
            return
        }
        do {
            if isFavorite {
                let input = FavoriteCharacterInput(
                    id: character.id,
                    name: character.name,
                    thumbnailURL: character.thumbnail.secureUrl
                )
                try await service.addFavorite(character: input)
            } else {
                try await service.removeFavorite(characterId: character.id)
            }
        } catch {
            print("❌ Erro ao salvar favorito: \(error)")
            isFavorite.toggle()
        }
    }
}
