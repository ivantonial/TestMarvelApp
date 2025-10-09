//
//  NetworkService.swift
//  Networking
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Alamofire
import Core
import Foundation

/// Protocolo para endpoints da API
public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

/// Protocolo para serviços de rede
public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

/// Erro personalizado de rede
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "Nenhum dado recebido"
        case .decodingError(let error):
            return "Erro ao decodificar: \(error.localizedDescription)"
        case .serverError(let code):
            return "Erro do servidor: \(code)"
        case .unknown(let error):
            return "Erro desconhecido: \(error.localizedDescription)"
        }
    }
}
