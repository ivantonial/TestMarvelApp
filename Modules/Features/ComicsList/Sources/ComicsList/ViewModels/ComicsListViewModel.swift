//
//  ComicsListViewModel.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class ComicsListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var comics: [Comic] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var selectedFilter: ComicFilter = .all
    @Published public var hasMorePages = true
    @Published public var selectedComic: Comic?

    // MARK: - Public Properties
    public let character: Character

    // MARK: - Private Properties
    private let fetchCharacterComicsUseCase: FetchCharacterComicsUseCase
    private var currentOffset = 0
    private let pageSize = 20
    private var allComics: [Comic] = []

    // MARK: - Computed Properties
    public var filteredComics: [Comic] {
        switch selectedFilter {
        case .all:
            return comics
        case .recent:
            // Ordenar por data de lançamento (mais recentes primeiro)
            return comics.sorted { _, _ in
                // Assumindo que temos uma propriedade de data
                // Por enquanto, retorna na ordem original
                return true
            }
        case .popular:
            // Filtrar/ordenar por popularidade
            // Por enquanto, retorna os primeiros 10
            return Array(comics.prefix(10))
        case .classic:
            // Filtrar quadrinhos clássicos
            // Por enquanto, retorna os últimos 10
            return Array(comics.suffix(10))
        }
    }

    public var totalComics: Int {
        character.comics.available
    }

    public var hasFilters: Bool {
        comics.count > 5
    }

    // MARK: - Initialization
    public init(
        character: Character,
        fetchCharacterComicsUseCase: FetchCharacterComicsUseCase
    ) {
        self.character = character
        self.fetchCharacterComicsUseCase = fetchCharacterComicsUseCase
    }

    // MARK: - Public Methods
    public func loadInitialData() {
        Task {
            await loadComics(isInitial: true)
        }
    }

    public func loadMoreIfNeeded(currentComic: Comic) {
        guard let lastComic = comics.last,
              lastComic.id == currentComic.id,
              !isLoading,
              hasMorePages else { return }

        Task {
            await loadComics(isInitial: false)
        }
    }

    public func refresh() {
        Task {
            currentOffset = 0
            hasMorePages = true
            await loadComics(isInitial: true)
        }
    }

    public func selectFilter(_ filter: ComicFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = filter
        }
    }

    public func selectComic(_ comic: Comic) {
        selectedComic = comic
        // Aqui você pode navegar para uma tela de detalhes do quadrinho
        // ou mostrar um modal/sheet
        showComicDetail(comic)
    }

    // MARK: - Private Methods
    private func loadComics(isInitial: Bool) async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let result = try await fetchCharacterComicsUseCase.execute(
                characterId: character.id,
                offset: currentOffset,
                limit: pageSize
            )

            if isInitial {
                comics = result
                allComics = result
            } else {
                comics.append(contentsOf: result)
                allComics.append(contentsOf: result)
            }

            currentOffset += pageSize
            hasMorePages = result.count == pageSize

        } catch {
            self.error = error
            print("Erro ao carregar quadrinhos: \(error)")
        }
    }

    private func showComicDetail(_ comic: Comic) {
        // Implementar navegação ou apresentação de detalhes
        // Por exemplo, usando um sheet ou navegação
        print("Comic selecionado: \(comic.title)")
    }
}
