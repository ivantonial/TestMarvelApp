//
//  CacheManagerProtocol.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public protocol CacheManagerProtocol: Sendable {
    func getCacheSize() async -> Int
    func clearAll() async
}

public extension FileManager {
    func sizeOfDirectory(at url: URL) throws -> Int {
        var size = 0
        let contents = try contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey])
        for item in contents {
            let itemSize = try item.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            size += itemSize
        }
        return size
    }
}
