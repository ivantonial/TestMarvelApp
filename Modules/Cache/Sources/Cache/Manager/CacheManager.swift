//
//  CacheManager.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import Foundation
import MarvelAPI
import UIKit

public final class CacheManager: CacheManagerProtocol, @unchecked Sendable {
    public static let shared = CacheManager()

    private let memoryCache = NSCache<NSString, CacheEntry>()
    private let diskCacheURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let maxMemoryCost = 50 * 1024 * 1024 // 50 MB
    private let defaultExpiration: TimeInterval = 3600 // 1h
    private let queue = DispatchQueue(label: "com.marvel.cache", attributes: .concurrent)

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = caches.appendingPathComponent("MarvelCache")
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        memoryCache.totalCostLimit = maxMemoryCost
        setupObservers()
    }

    // MARK: - Core
    public func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        let sanitized = sanitize(key)
        let data = try? encoder.encode(object)
        let entry = CacheEntry(data: data, expiration: Date().addingTimeInterval(defaultExpiration))
        queue.async(flags: .barrier) {
            self.memoryCache.setObject(entry, forKey: sanitized as NSString)
            let url = self.diskCacheURL.appendingPathComponent(sanitized)
            try? data?.write(to: url)
            try? self.encoder.encode(CacheMetadata(expirationDate: entry.expiration))
                .write(to: url.appendingPathExtension("meta"))
        }
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T? {
        let sanitized = sanitize(key)
        return await withCheckedContinuation { cont in
            queue.async {
                if let entry = self.memoryCache.object(forKey: sanitized as NSString),
                   entry.expiration > Date(),
                   let data = entry.data,
                   let obj = try? self.decoder.decode(type, from: data) {
                    return cont.resume(returning: obj)
                }

                let url = self.diskCacheURL.appendingPathComponent(sanitized)
                guard let data = try? Data(contentsOf: url) else {
                    return cont.resume(returning: nil)
                }
                let metaURL = url.appendingPathExtension("meta")
                if let meta = try? Data(contentsOf: metaURL),
                   let info = try? self.decoder.decode(CacheMetadata.self, from: meta),
                   info.expirationDate < Date() {
                    try? FileManager.default.removeItem(at: url)
                    try? FileManager.default.removeItem(at: metaURL)
                    return cont.resume(returning: nil)
                }
                let newEntry = CacheEntry(data: data, expiration: Date().addingTimeInterval(self.defaultExpiration))
                self.memoryCache.setObject(newEntry, forKey: sanitized as NSString)
                cont.resume(returning: try? self.decoder.decode(type, from: data))
            }
        }
    }

    public func remove(forKey key: String) async {
        let sanitized = sanitize(key)
        queue.async(flags: .barrier) {
            self.memoryCache.removeObject(forKey: sanitized as NSString)
            let file = self.diskCacheURL.appendingPathComponent(sanitized)
            try? FileManager.default.removeItem(at: file)
            try? FileManager.default.removeItem(at: file.appendingPathExtension("meta"))
        }
    }

    public func clearAll() async {
        queue.async(flags: .barrier) {
            self.memoryCache.removeAllObjects()
            try? FileManager.default.removeItem(at: self.diskCacheURL)
            try? FileManager.default.createDirectory(at: self.diskCacheURL, withIntermediateDirectories: true)
        }
    }

    public func getCacheSize() async -> Int {
        (try? FileManager.default.sizeOfDirectory(at: diskCacheURL)) ?? 0
    }

    public func setExpirationDate(_ date: Date, forKey key: String) async {
        let file = diskCacheURL.appendingPathComponent(sanitize(key))
        let meta = CacheMetadata(expirationDate: date)
        try? encoder.encode(meta).write(to: file.appendingPathExtension("meta"))
    }

    public func isExpired(forKey key: String) async -> Bool {
        let meta = diskCacheURL.appendingPathComponent(sanitize(key)).appendingPathExtension("meta")
        guard let data = try? Data(contentsOf: meta),
              let m = try? decoder.decode(CacheMetadata.self, from: data)
        else { return true }
        return m.expirationDate < Date()
    }

    // MARK: - Helpers
    private func sanitize(_ key: String) -> String {
        key.replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "_", options: .regularExpression)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil,
                                               queue: .main) { _ in
            self.memoryCache.removeAllObjects()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                               object: nil,
                                               queue: .main) { _ in
            self.queue.async { try? self.cleanExpired() }
        }
    }

    private func cleanExpired() throws {
        let files = try FileManager.default.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: nil)
        for f in files where f.pathExtension != "meta" {
            if let meta = try? Data(contentsOf: f.appendingPathExtension("meta")),
               let info = try? decoder.decode(CacheMetadata.self, from: meta),
               info.expirationDate < Date() {
                try? FileManager.default.removeItem(at: f)
                try? FileManager.default.removeItem(at: f.appendingPathExtension("meta"))
            }
        }
    }
}

final class CacheEntry: NSObject, @unchecked Sendable {
    let data: Data?
    let expiration: Date
    init(data: Data?, expiration: Date) {
        self.data = data
        self.expiration = expiration
    }
}
