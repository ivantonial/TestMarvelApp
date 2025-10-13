//
//  DesignSystemColors+Extensions.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI

extension ColorType {
    public var swiftUIColor: Color {
        switch self {
        case .red:    return .red
        case .blue:   return .blue
        case .yellow: return .yellow
        case .green:  return .green
        case .gray:   return .gray
        }
    }
}
