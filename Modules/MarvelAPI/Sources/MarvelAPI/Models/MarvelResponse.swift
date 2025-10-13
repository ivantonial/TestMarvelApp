//
//  MarvelResponse.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

public struct MarvelResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let code: Int
    public let status: String
    public let copyright: String?
    public let attributionText: String?
    public let attributionHTML: String?
    public let etag: String?
    public let data: MarvelDataContainer<T>
}

public struct MarvelDataContainer<T: Decodable & Sendable>: Decodable, Sendable {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let count: Int
    public let results: [T]
}
