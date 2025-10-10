//
//  FavoritesViewModel.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Combine
import Core
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var favoriteCharacters: [Character] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var searchText = ""
    @Published public var sortOption: FavoritesSortOption = .dateAdded
    @Published public var selectedCharacters: Set<Int> = []
    @Published public var isSelectionMode = false

    // MARK: - Private Properties
    private let favoritesService: FavoritesService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    public var filteredCharacters: [Character] {
        let filtered = searchText.isEmpty
            ? favoriteCharacters
            : favoriteCharacters.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }

        return sortCharacters(filtered)
    }

    public var hasFavorites: Bool {
        !favoriteCharacters.isEmpty
    }

    public var selectedCount: Int {
        selectedCharacters.count
    }

    public var isAllSelected: Bool {
        !filteredCharacters.isEmpty && selectedCharacters.count == filteredCharacters.count
    }

    // MARK: - Initialization
    public init(favoritesService: FavoritesService? = nil) {
        self.favoritesService = favoritesService ?? FavoritesService.shared
        setupObservers()
        loadFavorites()
    }

    // MARK: - Public Methods
    public func loadFavorites() {
        isLoading = true
        error = nil

        Task {
            defer { isLoading = false }
            do {
                favoriteCharacters = try await favoritesService.getAllFavorites()
            } catch {
                self.error = error
                print("❌ Erro ao carregar favoritos: \(error)")
            }
        }
    }

    public func removeFavorite(_ character: Character) {
        Task {
            do {
                try await favoritesService.removeFavorite(characterId: character.id)
                withAnimation(.easeOut(duration: 0.3)) {
                    favoriteCharacters.removeAll { $0.id == character.id }
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } catch {
                print("❌ Erro ao remover favorito: \(error)")
            }
        }
    }

    public func removeSelectedFavorites() {
        let charactersToRemove = filteredCharacters.filter {
            selectedCharacters.contains($0.id)
        }

        Task {
            for character in charactersToRemove {
                try? await favoritesService.removeFavorite(characterId: character.id)
            }

            withAnimation {
                favoriteCharacters.removeAll { character in
                    selectedCharacters.contains(character.id)
                }
                selectedCharacters.removeAll()
                isSelectionMode = false
            }
        }
    }

    public func toggleSelection(for character: Character) {
        if selectedCharacters.contains(character.id) {
            selectedCharacters.remove(character.id)
        } else {
            selectedCharacters.insert(character.id)
        }
    }

    public func selectAll() {
        selectedCharacters = Set(filteredCharacters.map { $0.id })
    }

    public func deselectAll() {
        selectedCharacters.removeAll()
    }

    public func toggleSelectionMode() {
        withAnimation {
            isSelectionMode.toggle()
            if !isSelectionMode {
                selectedCharacters.removeAll()
            }
        }
    }

    public func updateSortOption(_ option: FavoritesSortOption) {
        withAnimation(.easeInOut(duration: 0.2)) {
            sortOption = option
        }
    }

    public func exportFavorites() -> String {
        let list = favoriteCharacters.map { "• \($0.name)" }.joined(separator: "\n")
        return "My Marvel Favorites:\n\n\(list)"
    }

    // MARK: - Private Methods
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.loadFavorites() }
            .store(in: &cancellables)
    }

    private func sortCharacters(_ characters: [Character]) -> [Character] {
        switch sortOption {
        case .dateAdded:
            return characters
        case .name:
            return characters.sorted { $0.name < $1.name }
        case .mostComics:
            return characters.sorted { $0.comics.available > $1.comics.available }
        }
    }
}
