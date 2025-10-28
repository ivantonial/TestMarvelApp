//
//  CharacterListViewModel.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Core
import Foundation
import MarvelAPI
import SwiftUI
import Combine
import Networking
import Cache

@MainActor
public final class CharacterListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var characters: [Character] = []
    @Published public var searchResults: [Character] = []
    @Published public var isLoading = false
    @Published public var isSearching = false
    @Published public var error: Error?
    @Published public var hasMorePages = true
    @Published public var searchText = ""

    // MARK: - Private Properties
    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let searchCharactersUseCase: CharacterListSearchUseCase
    private var currentOffset = 0
    private let pageSize = 20
    private var searchTask: Task<Void, Never>?
    private var searchCancellable: AnyCancellable?
    private var loadTask: Task<Void, Never>?

    // MARK: - Computed Properties
    public var displayCharacters: [Character] {
        if !searchText.isEmpty && !searchResults.isEmpty {
            return searchResults
        }
        return characters
    }

    public var characterCardModels: [CharacterCardModel] {
        // Remove duplicatas baseado no ID antes de criar os models
        let uniqueCharacters = displayCharacters.reduce(into: [Character]()) { result, character in
            if !result.contains(where: { $0.id == character.id }) {
                result.append(character)
            }
        }
        return uniqueCharacters.map { CharacterCardModel(from: $0) }
    }

    // MARK: - Initialization
    public init(fetchCharactersUseCase: FetchCharactersUseCase,
                marvelService: MarvelServiceProtocol? = nil) {
        self.fetchCharactersUseCase = fetchCharactersUseCase

        // Sempre cria o use case de busca
        if let service = marvelService {
            self.searchCharactersUseCase = CharacterListSearchUseCase(service: service)
        } else {
            let networkService = NetworkService()
            let marvelService = MarvelService(networkService: networkService)
            self.searchCharactersUseCase = CharacterListSearchUseCase(service: marvelService)
        }

        setupSearchDebounce()
    }

    // MARK: - Search Setup
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }

                if searchText.isEmpty {
                    self.clearSearch()
                } else if searchText.count >= 2 { // Busca apenas com 2+ caracteres
                    self.performSearch(query: searchText)
                }
            }
    }

    // MARK: - Public Methods
    public func loadInitialData() {
        // Cancela carregamento anterior se houver
        loadTask?.cancel()

        loadTask = Task {
            await loadCharacters(isInitial: true)
        }
    }

    public func loadMoreIfNeeded(currentCharacter: Character) {
        // Não carrega mais se estiver buscando
        guard searchText.isEmpty else { return }

        guard let lastCharacter = characters.last,
              lastCharacter.id == currentCharacter.id,
              !isLoading,
              hasMorePages else { return }

        loadTask?.cancel()
        loadTask = Task {
            await loadCharacters(isInitial: false)
        }
    }

    /// Método de refresh síncrono (mantido para compatibilidade)
    public func refresh() {
        searchText = ""
        searchResults = []

        // Cancela tarefas anteriores
        searchTask?.cancel()
        loadTask?.cancel()

        loadTask = Task {
            currentOffset = 0
            hasMorePages = true
            characters = [] // Limpa a lista antes de recarregar
            await loadCharacters(isInitial: true)
        }
    }

    /// Método de refresh assíncrono para pull-to-refresh
    public func refreshAsync() async {
        searchText = ""
        searchResults = []

        // Cancela tarefas anteriores
        searchTask?.cancel()
        loadTask?.cancel()

        currentOffset = 0
        hasMorePages = true
        characters = [] // Limpa a lista antes de recarregar
        await loadCharacters(isInitial: true)
    }

    // MARK: - Search Methods
    private func performSearch(query: String) {
        // Cancela busca anterior
        searchTask?.cancel()

        searchTask = Task {
            isSearching = true
            error = nil

            do {
                let results = try await searchCharactersUseCase.execute(
                    query: query,
                    offset: 0,
                    limit: 30
                )

                // Verifica se não foi cancelado
                if !Task.isCancelled {
                    // Remove duplicatas dos resultados de busca
                    let uniqueResults = results.reduce(into: [Character]()) { result, character in
                        if !result.contains(where: { $0.id == character.id }) {
                            result.append(character)
                        }
                    }
                    searchResults = uniqueResults
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                    print("❌ Erro na busca: \(error)")
                }
            }

            isSearching = false
        }
    }

    private func clearSearch() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
    }

    // MARK: - Private Methods
    private func loadCharacters(isInitial: Bool) async {
        isLoading = true

        // Limpa erros anteriores ao iniciar novo carregamento
        if isInitial {
            error = nil
        }

        defer {
            isLoading = false
        }

        do {
            let result = try await fetchCharactersUseCase.execute(
                offset: currentOffset,
                limit: pageSize
            )

            // Verifica se a task não foi cancelada
            guard !Task.isCancelled else { return }

            if isInitial {
                // Para carregamento inicial, substitui toda a lista
                characters = result
                // Limpa qualquer erro anterior em caso de sucesso
                error = nil
            } else {
                // Para paginação, adiciona apenas itens que ainda não estão na lista
                let newCharacters = result.filter { newChar in
                    !characters.contains(where: { $0.id == newChar.id })
                }
                characters.append(contentsOf: newCharacters)
            }

            currentOffset += pageSize
            hasMorePages = result.count == pageSize
        } catch {
            // Só define o erro se a task não foi cancelada
            if !Task.isCancelled {
                self.error = error
                print("❌ Erro ao carregar personagens: \(error)")

                // Se for carregamento inicial e houve erro, limpa a lista
                if isInitial {
                    characters = []
                }
            }
        }
    }

    // MARK: - Cleanup
    // AnyCancellable se cancela automaticamente quando desalocado
    // Tasks podem ser canceladas no deinit pois são Sendable
    deinit {
        searchTask?.cancel()
        loadTask?.cancel()
    }
}
