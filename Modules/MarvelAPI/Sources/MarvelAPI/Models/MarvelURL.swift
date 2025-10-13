//
//  MarvelURL.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import Core

public struct MarvelURL: Decodable, Sendable {
    public let type: URLType
    public let url: String
}

public enum URLType: String, Decodable, UnknownCaseRepresentable, Sendable {
    case detail
    case wiki
    case comiclink
    case unknown

    public static let unknownCase = Self.unknown
}
