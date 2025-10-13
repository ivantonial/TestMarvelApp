//
//  ColorType.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import Foundation

/// Paleta de cores sem dependência de UI frameworks.
/// Essa camada é neutra (não importa se é UIKit ou SwiftUI).
public enum ColorType: Sendable {
    case red
    case blue
    case yellow
    case green
    case gray
}
