//
//  MarvelImage.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

public struct MarvelImage: Decodable, Sendable {
    public let path: String
    public let `extension`: String

    public init(path: String, extension: String) {
        self.path = path
        self.`extension` = `extension`
    }

    public var url: URL? { URL(string: "\(path).\(`extension`)") }

    public var secureUrl: URL? {
        let securePath = path.replacingOccurrences(of: "http://", with: "https://")
        return URL(string: "\(securePath).\(`extension`)")
    }
}
