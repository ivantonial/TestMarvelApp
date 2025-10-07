//
//  MarvelAPIService.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Foundation
import Networking
import Alamofire
import Crypto

// MARK: - Marvel API Configuration
public struct MarvelAPIConfig {
    public let publicKey: String
    public let privateKey: String
    public let baseURL: String

    public init(publicKey: String, privateKey: String, baseURL: String = "https://gateway.marvel.com/v1/public") {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.baseURL = baseURL
    }
}

// MARK: - Marvel API Endpoints
public enum MarvelEndpoint: APIEndpoint {
    case characters(offset: Int = 0, limit: Int = 20)
    case character(id: Int)
    case characterComics(characterId: Int, offset: Int = 0, limit: Int = 20)

    nonisolated(unsafe) private static var config: MarvelAPIConfig?

    public static func configure(with config: MarvelAPIConfig) {
        self.config = config
    }

    public var baseURL: String {
        guard let config = Self.config else {
            fatalError("MarvelAPI não configurada. Chame MarvelEndpoint.configure() primeiro.")
        }
        return config.baseURL
    }

    public var path: String {
        switch self {
        case .characters:
            return "/characters"
        case .character(let id):
            return "/characters/\(id)"
        case .characterComics(let characterId, _, _):
            return "/characters/\(characterId)/comics"
        }
    }

    public var method: HTTPMethod {
        return .get
    }

    public var headers: HTTPHeaders? {
        return ["Accept": "application/json"]
    }

    public var parameters: Parameters? {
        guard let config = Self.config else { return nil }

        let timestamp = String(Date().timeIntervalSince1970)
        let hash = generateHash(timestamp: timestamp,
                               privateKey: config.privateKey,
                               publicKey: config.publicKey)

        var params: Parameters = [
            "apikey": config.publicKey,
            "ts": timestamp,
            "hash": hash
        ]

        switch self {
        case .characters(let offset, let limit):
            params["offset"] = offset
            params["limit"] = limit

        case .characterComics(_, let offset, let limit):
            params["offset"] = offset
            params["limit"] = limit

        default:
            break
        }

        return params
    }

    public var encoding: ParameterEncoding {
        return URLEncoding.default
    }

    private func generateHash(timestamp: String, privateKey: String, publicKey: String) -> String {
        let data = "\(timestamp)\(privateKey)\(publicKey)".data(using: .utf8)!
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Marvel API Service
public protocol MarvelServiceProtocol: Sendable {
    func fetchCharacters(offset: Int, limit: Int) async throws -> [Character]
    func fetchCharacter(by id: Int) async throws -> Character
    func fetchCharacterComics(characterId: Int, offset: Int, limit: Int) async throws -> [Comic]
}

public final class MarvelService: MarvelServiceProtocol, @unchecked Sendable {

    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func fetchCharacters(offset: Int = 0, limit: Int = 20) async throws -> [Character] {
        let endpoint = MarvelEndpoint.characters(offset: offset, limit: limit)
        let response = try await networkService.request(endpoint,
                                                       responseType: MarvelResponse<Character>.self)
        return response.data.results
    }

    public func fetchCharacter(by id: Int) async throws -> Character {
        let endpoint = MarvelEndpoint.character(id: id)
        let response = try await networkService.request(endpoint,
                                                       responseType: MarvelResponse<Character>.self)
        guard let character = response.data.results.first else {
            throw NetworkError.noData
        }
        return character
    }

    public func fetchCharacterComics(characterId: Int, offset: Int = 0, limit: Int = 20) async throws -> [Comic] {
        let endpoint = MarvelEndpoint.characterComics(characterId: characterId,
                                                     offset: offset,
                                                     limit: limit)
        let response = try await networkService.request(endpoint,
                                                       responseType: MarvelResponse<Comic>.self)
        return response.data.results
    }
}

// MARK: - Comic Model
public struct Comic: Decodable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String?
    public let thumbnail: MarvelImage
}
