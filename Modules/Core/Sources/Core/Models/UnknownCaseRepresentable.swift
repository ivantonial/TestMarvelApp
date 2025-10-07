//
//  UnknownCaseRepresentable.swift
//  Core
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Foundation

/// Protocol para lidar com casos desconhecidos em enums decodificáveis
public protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable
    where RawValue: Decodable & Equatable {
    static var unknownCase: Self { get }
}

public extension UnknownCaseRepresentable where Self: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        guard let value = Self(rawValue: rawValue) else {
            self = Self.unknownCase
            return
        }
        self = value
    }
}
