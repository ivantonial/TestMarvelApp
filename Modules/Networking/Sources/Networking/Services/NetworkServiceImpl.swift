//  NetworkService.swift
//  Networking
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Alamofire
import Core
import Foundation

/// Implementação do serviço de rede usando Alamofire
@available(iOS 16.0, *)
public final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {

    private let session: Session
    private let decoder: JSONDecoder
    private let queue = DispatchQueue(label: "com.marvelapp.networkservice")

    public init(session: Session = .default) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint,
                                                 responseType: T.Type) async throws -> T {

        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url,
                            method: endpoint.method,
                            parameters: endpoint.parameters,
                            encoding: endpoint.encoding,
                            headers: endpoint.headers)
            .validate()
            .responseData(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decodedObject = try self.decoder.decode(T.self, from: data)
                        continuation.resume(returning: decodedObject)
                    } catch {
                        continuation.resume(throwing: NetworkError.decodingError(error))
                    }

                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        continuation.resume(throwing: NetworkError.serverError(statusCode))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown(error))
                    }
                }
            }
        }
    }
}
