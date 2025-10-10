//
//  PersistenceManager.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import CoreData
import Foundation
import MarvelAPI

// MARK: - Protocolo
public protocol PersistenceManagerProtocol: Sendable {
    func saveCharacters(_ characters: [Character]) async throws
    func loadCharacters(offset: Int, limit: Int) async -> [Character]
    func saveCharacter(_ character: Character) async throws
    func loadCharacter(withId id: Int) async -> Character?

    func saveComics(_ comics: [Comic], forCharacterId characterId: Int) async throws
    func loadComics(forCharacterId characterId: Int) async -> [Comic]

    func saveFavorite(_ character: Character) async throws
    func removeFavorite(characterId: Int) async throws
    func loadFavorites() async -> [Character]
    func isFavorite(characterId: Int) async -> Bool

    func saveSearchHistory(_ query: String, resultCount: Int) async
    func loadSearchHistory() async -> [String]
    func clearSearchHistory() async

    func clearAllCache() async throws
    func getCacheAge() async -> TimeInterval?
}

// MARK: - Implementação
public final class PersistenceManager: PersistenceManagerProtocol, @unchecked Sendable {
    // MARK: - Propriedades
    private let coreDataStack: CoreDataStack
    private let cacheExpirationInterval: TimeInterval = 3600 // 1 hora

    // MARK: - Inicialização
    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Characters
    public func saveCharacters(_ characters: [Character]) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            let old = try context.fetch(fetch)
            old.forEach { context.delete($0) }

            for character in characters {
                let cd = CDCharacter(context: context)
                cd.update(from: character)
            }

            try context.save()
        }
    }

    public func loadCharacters(offset: Int = 0, limit: Int = 20) async -> [Character] {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fetch.fetchOffset = offset
            fetch.fetchLimit = limit
            fetch.predicate = NSPredicate(format: "cachedAt > %@",
                                          Date().addingTimeInterval(-self.cacheExpirationInterval) as CVarArg)

            do {
                let cdCharacters = try context.fetch(fetch)
                return cdCharacters.compactMap { $0.toCharacter() }
            } catch {
                print("⚠️ Erro ao carregar personagens: \(error)")
                return []
            }
        }
    }

    public func saveCharacter(_ character: Character) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", character.id)

            let cd: CDCharacter
            if let existing = try context.fetch(fetch).first {
                cd = existing
            } else {
                cd = CDCharacter(context: context)
            }
            cd.update(from: character)
            try context.save()
        }
    }

    public func loadCharacter(withId id: Int) async -> Character? {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", id)
            fetch.fetchLimit = 1
            do {
                return try context.fetch(fetch).first?.toCharacter()
            } catch {
                print("⚠️ Erro ao carregar personagem: \(error)")
                return nil
            }
        }
    }

    // MARK: - Comics
    public func saveComics(_ comics: [Comic], forCharacterId characterId: Int) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            let fetch: NSFetchRequest<CDComic> = CDComic.fetchRequest()
            fetch.predicate = NSPredicate(format: "characterId == %d", characterId)
            let oldComics = try context.fetch(fetch)
            oldComics.forEach { context.delete($0) }

            for comic in comics {
                let cd = CDComic(context: context)
                cd.update(from: comic, characterId: characterId)
            }

            try context.save()
        }
    }

    public func loadComics(forCharacterId characterId: Int) async -> [Comic] {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDComic> = CDComic.fetchRequest()
            fetch.predicate = NSPredicate(format: "characterId == %d", characterId)
            fetch.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            do {
                let cdComics = try context.fetch(fetch)
                return cdComics.compactMap { $0.toComic() }
            } catch {
                print("⚠️ Erro ao carregar quadrinhos: \(error)")
                return []
            }
        }
    }

    // MARK: - Favoritos
    public func saveFavorite(_ character: Character) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", character.id)

            let cd: CDCharacter
            if let existing = try context.fetch(fetch).first {
                cd = existing
            } else {
                cd = CDCharacter(context: context)
                cd.update(from: character)
            }
            cd.isFavorite = true
            try context.save()
        }
    }

    public func removeFavorite(characterId: Int) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", characterId)
            if let cd = try context.fetch(fetch).first {
                cd.isFavorite = false
                try context.save()
            }
        }
    }

    public func loadFavorites() async -> [Character] {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "isFavorite == YES")
            fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                return try context.fetch(fetch).compactMap { $0.toCharacter() }
            } catch {
                print("⚠️ Erro ao carregar favoritos: \(error)")
                return []
            }
        }
    }

    public func isFavorite(characterId: Int) async -> Bool {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d AND isFavorite == YES", characterId)
            fetch.fetchLimit = 1
            do {
                return try context.count(for: fetch) > 0
            } catch {
                print("⚠️ Erro ao verificar favorito: \(error)")
                return false
            }
        }
    }

    // MARK: - Histórico de busca
    public func saveSearchHistory(_ query: String, resultCount: Int) async {
        let context = coreDataStack.newBackgroundContext()
        await context.perform {
            let fetch: NSFetchRequest<CDSearchHistory> = CDSearchHistory.fetchRequest()
            fetch.predicate = NSPredicate(format: "query == %@", query)

            do {
                if let existing = try context.fetch(fetch).first {
                    existing.timestamp = Date()
                    existing.resultCount = Int32(resultCount)
                } else {
                    let new = CDSearchHistory(context: context)
                    new.query = query
                    new.timestamp = Date()
                    new.resultCount = Int32(resultCount)
                }
                try context.save()
            } catch {
                print("⚠️ Erro ao salvar histórico: \(error)")
            }
        }
    }

    public func loadSearchHistory() async -> [String] {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDSearchHistory> = CDSearchHistory.fetchRequest()
            fetch.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetch.fetchLimit = 10
            do {
                return try context.fetch(fetch).map { $0.query }
            } catch {
                print("⚠️ Erro ao carregar histórico: \(error)")
                return []
            }
        }
    }

    public func clearSearchHistory() async {
        let context = coreDataStack.newBackgroundContext()
        await context.perform {
            let fetch: NSFetchRequest<NSFetchRequestResult> = CDSearchHistory.fetchRequest()
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            do {
                try context.execute(delete)
                try context.save()
            } catch {
                print("⚠️ Erro ao limpar histórico: \(error)")
            }
        }
    }

    // MARK: - Cache Management
    public func clearAllCache() async throws {
        coreDataStack.clearAllData()
    }

    public func getCacheAge() async -> TimeInterval? {
        let context = coreDataStack.mainContext
        return await context.perform {
            let fetch: NSFetchRequest<CDCharacter> = CDCharacter.fetchRequest()
            fetch.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: true)]
            fetch.fetchLimit = 1
            do {
                if let oldest = try context.fetch(fetch).first,
                   let cached = oldest.cachedAt {
                    return Date().timeIntervalSince(cached)
                }
            } catch {
                print("⚠️ Erro ao obter idade do cache: \(error)")
            }
            return nil
        }
    }
}
