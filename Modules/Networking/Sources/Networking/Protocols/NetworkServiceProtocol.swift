//
//  NetworkService.swift
//  Networking
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Alamofire
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
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint,
                                          responseType: T.Type) async throws -> T
}
