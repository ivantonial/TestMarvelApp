//
//  SearchCharactersUseCase.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation
import MarvelAPI

/// Caso de uso responsável por executar buscas de personagens.
public final class SearchCharactersUseCase: Sendable {
    private let service: MarvelServiceProtocol

    public init(service: MarvelServiceProtocol) {
        self.service = service
    }

    public func execute(query: String, limit: Int = 20) async throws -> [Character] {
        // Busca personagens na API Marvel
        let characters = try await service.fetchCharacters(offset: 0, limit: limit)
        return characters.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
