//
//  CacheManagerProtocol.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public protocol CacheManagerProtocol: Sendable {
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T?
    func remove(forKey key: String) async
    func clearAll() async
    func getCacheSize() async -> Int
    func setExpirationDate(_ date: Date, forKey key: String) async
    func isExpired(forKey key: String) async -> Bool
}
