//
//  CharacterListViewModel.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

//import Core
//import Foundation
//import MarvelAPI
//import SwiftUI
//
//@MainActor
//public final class CharacterListViewModel: ObservableObject {
//    // MARK: - Published Properties
//    @Published public var characters: [Character] = []
//    @Published public var isLoading = false
//    @Published public var error: Error?
//    @Published public var hasMorePages = true
//    @Published public var searchText = ""
//
//    // MARK: - Private Properties
//    private let fetchCharactersUseCase: FetchCharactersUseCase
//    private var currentOffset = 0
//    private let pageSize = 20
//    private var allCharacters: [Character] = []
//
//    // MARK: - Computed Properties
//    public var filteredCharacters: [Character] {
//        guard !searchText.isEmpty else { return characters }
//        return characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//    }
//
//    public var characterCardModels: [CharacterCardModel] {
//        filteredCharacters.map { CharacterCardModel(from: $0) }
//    }
//
//    // MARK: - Initialization
//    public init(fetchCharactersUseCase: FetchCharactersUseCase) {
//        self.fetchCharactersUseCase = fetchCharactersUseCase
//    }
//
//    // MARK: - Public Methods
//    public func loadInitialData() {
//        Task {
//            await loadCharacters(isInitial: true)
//        }
//    }
//
//    public func loadMoreIfNeeded(currentCharacter: Character) {
//        guard let lastCharacter = characters.last,
//              lastCharacter.id == currentCharacter.id,
//              !isLoading,
//              hasMorePages else { return }
//
//        Task {
//            await loadCharacters(isInitial: false)
//        }
//    }
//
//    public func refresh() {
//        Task {
//            currentOffset = 0
//            hasMorePages = true
//            await loadCharacters(isInitial: true)
//        }
//    }
//
//    // MARK: - Private Methods
//    private func loadCharacters(isInitial: Bool) async {
//        isLoading = true
//        error = nil
//
//        defer { isLoading = false }
//
//        do {
//            let result = try await fetchCharactersUseCase.execute(offset: currentOffset, limit: pageSize)
//
//            if isInitial {
//                characters = result
//                allCharacters = result
//            } else {
//                characters.append(contentsOf: result)
//                allCharacters.append(contentsOf: result)
//            }
//
//            currentOffset += pageSize
//            hasMorePages = result.count == pageSize
//        } catch {
//            self.error = error
//            print("❌ Erro ao carregar personagens: \(error)")
//        }
//    }
//}
import Core
import Foundation
import MarvelAPI
import SwiftUI

@MainActor
public final class CharacterListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var characters: [Character] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var hasMorePages = true
    @Published public var searchText = ""

    // MARK: - Private Properties
    private let fetchCharactersUseCase: FetchCharactersUseCase
    private var currentOffset = 0
    private let pageSize = 20
    private var allCharacters: [Character] = []

    // MARK: - Computed Properties
    public var filteredCharacters: [Character] {
        guard !searchText.isEmpty else { return characters }
        return characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    public var characterCardModels: [CharacterCardModel] {
        filteredCharacters.map { CharacterCardModel(from: $0) }
    }

    // MARK: - Initialization
    public init(fetchCharactersUseCase: FetchCharactersUseCase) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
    }

    // MARK: - Public Methods
    public func loadInitialData() {
        Task {
            await loadCharacters(isInitial: true)
        }
    }

    public func loadMoreIfNeeded(currentCharacter: Character) {
        guard let lastCharacter = characters.last,
              lastCharacter.id == currentCharacter.id,
              !isLoading,
              hasMorePages else { return }

        Task {
            await loadCharacters(isInitial: false)
        }
    }

    public func refresh() {
        Task {
            currentOffset = 0
            hasMorePages = true
            await loadCharacters(isInitial: true)
        }
    }

    // MARK: - Private Methods
    private func loadCharacters(isInitial: Bool) async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let result = try await fetchCharactersUseCase.execute(offset: currentOffset, limit: pageSize)

            if isInitial {
                characters = result
                allCharacters = result
            } else {
                characters.append(contentsOf: result)
                allCharacters.append(contentsOf: result)
            }

            currentOffset += pageSize
            hasMorePages = result.count == pageSize
        } catch {
            self.error = error
            print("⌛ Erro ao carregar personagens: \(error)")
        }
    }
}
