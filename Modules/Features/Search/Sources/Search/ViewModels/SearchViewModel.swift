//
//  SearchViewModel.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Combine
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class SearchViewModel: ObservableObject {
    // MARK: - Input/State
    @Published public var searchText = ""
    @Published public var searchType: SearchType = .characters
    @Published public var selectedFilter: SearchFilter = .all
    @Published public var sortOption: SortOption = .name

    // MARK: - Outputs
    @Published public var characterResults: [Character] = []
    @Published public var comicResults: [Comic] = []
    @Published public var recentSearches: [String] = []
    @Published public var suggestions: [String] = []
    @Published public var isSearching = false
    @Published public var error: Error?

    // MARK: - Deps
    private let searchCharactersUseCase: SearchCharactersWithCacheUseCase
    private let searchComicsUseCase: SearchComicsWithCacheUseCase

    // MARK: - Infra
    private var searchCancellable: AnyCancellable?
    private var searchTask: Task<Void, Never>?
    private let debounceTime: TimeInterval = 0.5

    // MARK: - Computed UI
    public var hasResults: Bool {
        switch searchType {
        case .characters: return !characterResults.isEmpty
        case .comics:     return !comicResults.isEmpty
        }
    }

    public var currentFilters: [SearchFilter] {
        SearchFilter.filters(for: searchType)
    }

    public var filteredCharacters: [Character] {
        let base = applyCharacterFilters(characterResults)
        return applyCharacterSorting(base)
    }

    public var filteredComics: [Comic] {
        // Apply filters to comic results
        let filtered = applyComicFilters(comicResults)
        // Could add sorting here in the future
        return filtered
    }

    // MARK: - Init
    public init(marvelService: MarvelServiceProtocol) {
        self.searchCharactersUseCase = SearchCharactersWithCacheUseCase(service: marvelService)
        self.searchComicsUseCase     = SearchComicsWithCacheUseCase(service: marvelService)
        setupSearchDebounce()
        loadRecentSearches()
    }

    // MARK: - Public API
    public func search() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            clearResults()
            return
        }
        searchTask?.cancel()
        searchTask = Task { await performSearch(with: q) }
    }

    public func switchSearchType(_ type: SearchType) {
        guard type != searchType else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            searchType = type
            selectedFilter = .all
        }
        if !searchText.isEmpty { search() }
    }

    public func updateFilter(_ filter: SearchFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = filter
        }
    }

    public func updateSortOption(_ option: SortOption) {
        withAnimation(.easeInOut(duration: 0.2)) {
            sortOption = option
        }
    }

    public func clearSearch() {
        searchText = ""
        clearResults()
    }

    public func selectSuggestion(_ suggestion: String) {
        searchText = suggestion
        search()
    }

    public func selectRecentSearch(_ searchString: String) {
        searchText = searchString
        search()
    }

    public func removeRecentSearch(at index: Int) {
        guard index < recentSearches.count else { return }
        recentSearches.remove(at: index)
        saveRecentSearches()
    }

    public func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }

    // MARK: - Internal
    private func performSearch(with query: String) async {
        isSearching = true
        error = nil
        defer { isSearching = false }

        do {
            switch searchType {
            case .characters:
                let results = try await searchCharactersUseCase.execute(query: query, offset: 0, limit: 30)
                guard !Task.isCancelled else { return }
                characterResults = results
                generateSuggestions(from: results.map(\.name))

            case .comics:
                let results = try await searchComicsUseCase.execute(query: query, offset: 0, limit: 30)
                guard !Task.isCancelled else { return }
                comicResults = results
                // Para comics, precisamos processar os títulos para remover informações duplicadas de variantes
                let processedTitles = processComicTitles(results.map(\.title))
                generateSuggestions(from: processedTitles)
            }

            if hasResults { saveRecentSearch(query) }

        } catch {
            guard !Task.isCancelled else { return }
            self.error = error
            print("⚠️ Search error: \(error)")
        }
    }

    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .seconds(debounceTime), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty || text.count >= 2 {
                    self.search()
                }
            }
    }

    private func generateSuggestions(from items: [String]) {
        // Remove duplicados e filtra itens diferentes do texto atual
        let uniqueItems = Array(Set(items))
            .filter { $0.lowercased() != searchText.lowercased() }
            .sorted() // Ordena alfabeticamente para consistência

        suggestions = Array(uniqueItems.prefix(5))
    }

    // MARK: - Comic Title Processing
    private func processComicTitles(_ titles: [String]) -> [String] {
        var processedTitles: [String] = []
        var seenBaseTitles: Set<String> = []

        for title in titles {
            // Remove informações de variantes e edições para evitar duplicados
            let baseTitle = extractBaseComicTitle(from: title)

            // Adiciona apenas se não foi visto antes
            if !seenBaseTitles.contains(baseTitle) {
                seenBaseTitles.insert(baseTitle)
                processedTitles.append(baseTitle)
            }
        }

        return processedTitles
    }

    private func extractBaseComicTitle(from fullTitle: String) -> String {
        var baseTitle = fullTitle

        // Remove padrões comuns de variantes e edições
        let patternsToRemove = [
            #"\s*\(Variant\).*$"#,
            #"\s*\(.*Variant.*\).*$"#,
            #"\s*#\d+.*$"#,
            #"\s*\(\d{4}\).*$"#,
            #"\s*Vol\.\s*\d+.*$"#,
            #"\s*Volume\s*\d+.*$"#
        ]

        for pattern in patternsToRemove {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: baseTitle.utf16.count)
                baseTitle = regex.stringByReplacingMatches(
                    in: baseTitle,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
        }

        // Remove espaços extras e retorna
        return baseTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Character Filters
    private func applyCharacterFilters(_ characters: [Character]) -> [Character] {
        switch selectedFilter {
        case .all:
            return characters
        case .heroes:
            let villainKeywords = ["doom", "magneto", "thanos", "loki", "venom", "goblin", "octopus"]
            return characters.filter { nameNotContains($0.name, anyOf: villainKeywords) }
        case .villains:
            let villainKeywords = ["doom", "magneto", "thanos", "loki", "venom", "goblin", "octopus"]
            return characters.filter { nameContains($0.name, anyOf: villainKeywords) }
        case .teams:
            let teamKeywords = ["avengers", "x-men", "fantastic", "guardians", "defenders"]
            return characters.filter { nameContains($0.name, anyOf: teamKeywords) }
        case .ongoing, .completed, .special:
            // Ignorado para Characters
            return characters
        }
    }

    // MARK: - Comic Filters
    private func applyComicFilters(_ comics: [Comic]) -> [Comic] {
        switch selectedFilter {
        case .all:
            return comics
        case .ongoing:
            // Filter for ongoing series (exclude annuals and specials)
            return comics.filter { comic in
                !comic.title.lowercased().contains("annual") &&
                !comic.title.lowercased().contains("special") &&
                !comic.title.lowercased().contains("variant")
            }
        case .completed:
            // This would need more metadata from API, for now return all
            return comics
        case .special:
            // Filter for special issues and variants
            return comics.filter { comic in
                comic.title.lowercased().contains("annual") ||
                comic.title.lowercased().contains("special") ||
                comic.title.lowercased().contains("variant")
            }
        default:
            return comics
        }
    }

    private func applyCharacterSorting(_ characters: [Character]) -> [Character] {
        switch sortOption {
        case .name:
            return characters.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .popularity:
            return characters.sorted { $0.comics.available > $1.comics.available }
        case .recent:
            return characters.sorted { $0.modified > $1.modified }
        }
    }

    private func nameContains(_ name: String, anyOf keywords: [String]) -> Bool {
        keywords.contains { name.localizedCaseInsensitiveContains($0) }
    }

    private func nameNotContains(_ name: String, anyOf keywords: [String]) -> Bool {
        !nameContains(name, anyOf: keywords)
    }

    // MARK: - Recent Searches
    private func loadRecentSearches() {
        let key = "RecentSearches_\(searchType.rawValue)"
        recentSearches = UserDefaults.standard.array(forKey: key) as? [String] ?? []
    }

    private func saveRecentSearch(_ query: String) {
        let key = "RecentSearches_\(searchType.rawValue)"
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > 10 { recentSearches = Array(recentSearches.prefix(10)) }

        UserDefaults.standard.set(recentSearches, forKey: key)
    }

    private func saveRecentSearches() {
        let key = "RecentSearches_\(searchType.rawValue)"
        UserDefaults.standard.set(recentSearches, forKey: key)
    }

    // MARK: - Util
    public func clearResults() {
        characterResults = []
        comicResults = []
        isSearching = false
        error = nil
        suggestions = []
    }
}
