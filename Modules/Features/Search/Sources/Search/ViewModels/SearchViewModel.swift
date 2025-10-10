//
//  SearchViewModel.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Combine
import Core
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published public var searchText = ""
    @Published public var searchResults: [Character] = []
    @Published public var recentSearches: [String] = []
    @Published public var suggestions: [String] = []
    @Published public var isSearching = false
    @Published public var error: Error?
    @Published public var selectedFilter: SearchFilter = .all
    @Published public var sortOption: SortOption = .name

    private let searchCharactersUseCase: SearchCharactersUseCase
    private var searchCancellable: AnyCancellable?
    private var searchTask: Task<Void, Never>?
    private let debounceTime: TimeInterval = 0.5

    // Computed properties
    public var hasResults: Bool {
        !searchResults.isEmpty
    }

    public var filteredResults: [Character] {
        searchResults
    }

    public init(searchCharactersUseCase: SearchCharactersUseCase) {
        self.searchCharactersUseCase = searchCharactersUseCase
        setupSearchDebounce()
        loadRecentSearches()
    }

    // MARK: - Search Logic
    public func search() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearResults()
            return
        }

        // Cancela busca anterior se ainda estiver executando
        searchTask?.cancel()

        // Criar nova task de busca
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            await self.performSearch()
        }
    }

    private func performSearch() async {
        isSearching = true
        error = nil
        defer { isSearching = false }

        do {
            let query = searchText

            // Executa a busca diretamente sem capturar o use case
            // Como searchCharactersUseCase é Sendable, isso é seguro
            let allResults = try await searchCharactersUseCase.execute(
                query: query,
                limit: 50
            )

            // Aplica filtros e ordenação
            let filteredResults = applyFilters(to: allResults)
            let sortedResults = applySorting(to: filteredResults)

            // Atualiza os resultados
            searchResults = sortedResults
            generateSuggestions(from: allResults)

            if !sortedResults.isEmpty {
                saveRecentSearch(query)
            }

        } catch {
            self.error = error
            print("❌ Erro na busca: \(error)")
        }
    }

    private func applyFilters(to characters: [Character]) -> [Character] {
        switch selectedFilter {
        case .all:
            return characters
        case .heroes:
            return characters.filter { character in
                !character.name.localizedCaseInsensitiveContains("doom") &&
                !character.name.localizedCaseInsensitiveContains("magneto") &&
                !character.name.localizedCaseInsensitiveContains("thanos")
            }
        case .villains:
            return characters.filter { character in
                character.name.localizedCaseInsensitiveContains("doom") ||
                character.name.localizedCaseInsensitiveContains("magneto") ||
                character.name.localizedCaseInsensitiveContains("thanos") ||
                character.name.localizedCaseInsensitiveContains("loki")
            }
        case .teams:
            return characters.filter { character in
                character.name.localizedCaseInsensitiveContains("man") ||
                character.name.localizedCaseInsensitiveContains("woman") ||
                character.comics.available > 20
            }
        }
    }

    private func applySorting(to characters: [Character]) -> [Character] {
        switch sortOption {
        case .name:
            return characters.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .popularity:
            return characters.sorted { $0.comics.available > $1.comics.available }
        case .recent:
            return characters.sorted { $0.modified > $1.modified }
        }
    }

    // MARK: - Helpers
    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .seconds(debounceTime), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.search()
            }
    }

    private func generateSuggestions(from characters: [Character]) {
        suggestions = characters.prefix(5).map { $0.name }.filter { $0 != searchText }
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.array(forKey: "RecentSearches") as? [String] ?? []
    }

    private func saveRecentSearch(_ searchQuery: String) {
        let trimmedText = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Remove se já existir para evitar duplicatas
        recentSearches.removeAll { $0.lowercased() == trimmedText.lowercased() }

        // Adiciona no início da lista
        recentSearches.insert(trimmedText, at: 0)

        // Limita a 10 buscas recentes
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }

        // Salva no UserDefaults
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }

    // MARK: - Public UI Methods
    public func clearSearch() {
        searchText = ""
        clearResults()
    }

    public func clearResults() {
        searchResults = []
        isSearching = false
        error = nil
        suggestions = []
    }

    public func updateFilter(_ filter: SearchFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = filter
            // Reaplica filtros se já temos resultados
            if !searchResults.isEmpty && !searchText.isEmpty {
                search()
            }
        }
    }

    public func updateSortOption(_ option: SortOption) {
        withAnimation(.easeInOut(duration: 0.2)) {
            sortOption = option
            // Reaplica ordenação se já temos resultados
            if !searchResults.isEmpty && !searchText.isEmpty {
                search()
            }
        }
    }

    public func selectRecentSearch(_ search: String) {
        searchText = search
        self.search()
    }

    public func selectSuggestion(_ suggestion: String) {
        searchText = suggestion
        self.search()
    }

    public func removeRecentSearch(at index: Int) {
        guard index < recentSearches.count else { return }
        recentSearches.remove(at: index)
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }

    public func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: "RecentSearches")
    }
}
