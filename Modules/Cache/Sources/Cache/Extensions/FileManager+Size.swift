//
//  FileManager+Size.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

public extension FileManager {
    func sizeOfDirectory(at url: URL) throws -> Int {
        var size = 0
        let contents = try contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey])
        for item in contents {
            size += try item.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        }
        return size
    }
}
