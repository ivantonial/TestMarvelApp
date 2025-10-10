//
//  NetworkError.swift
//  Networking
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Foundation

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
