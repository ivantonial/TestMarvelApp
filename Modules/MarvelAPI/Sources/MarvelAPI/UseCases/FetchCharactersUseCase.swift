//
//  FetchCharactersUseCase.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Foundation

/// Use Case para buscar lista de personagens
public final class FetchCharactersUseCase: Sendable {
    private let service: MarvelServiceProtocol

    public init(service: MarvelServiceProtocol) {
        self.service = service
    }

    public func execute(offset: Int = 0, limit: Int = 20) async throws -> [Character] {
        try await service.fetchCharacters(offset: offset, limit: limit)
    }
}

/// Use Case para buscar detalhes de um personagem
public final class FetchCharacterDetailUseCase: Sendable {
    private let service: MarvelServiceProtocol

    public init(service: MarvelServiceProtocol) {
        self.service = service
    }

    public func execute(characterId: Int) async throws -> Character {
        try await service.fetchCharacter(by: characterId)
    }
}

/// Use Case para buscar quadrinhos de um personagem
public final class FetchCharacterComicsUseCase: Sendable {
    private let service: MarvelServiceProtocol

    public init(service: MarvelServiceProtocol) {
        self.service = service
    }

    public func execute(characterId: Int, offset: Int = 0, limit: Int = 20) async throws -> [Comic] {
        try await service.fetchCharacterComics(characterId: characterId, offset: offset, limit: limit)
    }
}
