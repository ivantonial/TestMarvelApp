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
    // MARK: - Published Properties
    @Published public var detailModel: CharacterDetailModel
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var isFavorite = false

    // MARK: - Private Properties
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase?
    private let fetchCharacterComicsUseCase: FetchCharacterComicsUseCase?
    private let favoritesService: FavoritesServiceProtocol?

    // MARK: - Computed Properties
    public var hasRelatedContent: Bool {
        detailModel.relatedContent.hasContent
    }

    public var hasComics: Bool {
        detailModel.character.comics.available > 0
    }

    public var shareItems: [Any] {
        detailModel.shareInfo.shareItems
    }

    // MARK: - Initialization
    public init(
        character: MarvelAPI.Character,
        fetchCharacterDetailUseCase: FetchCharacterDetailUseCase? = nil,
        fetchCharacterComicsUseCase: FetchCharacterComicsUseCase? = nil,
        favoritesService: FavoritesServiceProtocol? = nil
    ) {
        self.detailModel = CharacterDetailModel(from: character)
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
        self.fetchCharacterComicsUseCase = fetchCharacterComicsUseCase
        self.favoritesService = favoritesService
        loadInitialData()
    }

    // MARK: - Public Methods
    public func loadCharacterDetails() {
        guard fetchCharacterDetailUseCase != nil else { return }
        Task { await fetchFullCharacterDetails() }
    }

    public func toggleFavorite() {
        Task { await toggleFavoriteAsync() }
    }

    public func refresh() {
        Task { await fetchFullCharacterDetails() }
    }

    // MARK: - Private Methods
    private func loadInitialData() {
        Task { await loadFavoriteStatus() }
    }

    private func fetchFullCharacterDetails() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            if let useCase = fetchCharacterDetailUseCase {
                let updatedCharacter = try await useCase.execute(characterId: detailModel.character.id)
                detailModel = CharacterDetailModel(from: updatedCharacter)
            }

            if let comicsUseCase = fetchCharacterComicsUseCase {
                _ = try await comicsUseCase.execute(characterId: detailModel.character.id, limit: 10)
            }
        } catch {
            self.error = error
            print("⌛ Erro ao carregar detalhes: \(error)")
        }
    }

    private func toggleFavoriteAsync() async {
        isFavorite.toggle()
        await saveFavoriteStatus()

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }

    private func loadFavoriteStatus() async {
        guard let service = favoritesService else {
            let favorites = UserDefaults.standard.array(forKey: "FavoriteCharacters") as? [Int] ?? []
            isFavorite = favorites.contains(detailModel.character.id)
            return
        }
        isFavorite = await service.isFavorite(characterId: detailModel.character.id)
    }

    private func saveFavoriteStatus() async {
        guard let service = favoritesService else {
            saveFavoriteToUserDefaults()
            return
        }

        do {
            if isFavorite {
                let input = FavoriteCharacterInput(
                    id: detailModel.character.id,
                    name: detailModel.character.name,
                    thumbnailURL: detailModel.character.thumbnail.secureUrl
                )
                try await service.addFavorite(character: input)
            } else {
                try await service.removeFavorite(characterId: detailModel.character.id)
            }
        } catch {
            print("⌛ Erro ao salvar favorito: \(error)")
            isFavorite.toggle() // Reverte em caso de erro
        }
    }

    private func saveFavoriteToUserDefaults() {
        var favorites = UserDefaults.standard.array(forKey: "FavoriteCharacters") as? [Int] ?? []
        if isFavorite {
            if !favorites.contains(detailModel.character.id) {
                favorites.append(detailModel.character.id)
            }
        } else {
            favorites.removeAll { $0 == detailModel.character.id }
        }
        UserDefaults.standard.set(favorites, forKey: "FavoriteCharacters")
    }
}
