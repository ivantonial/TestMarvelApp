//
//  ContentCardConvertible.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation
import SwiftUI

/// Protocolo que define a capacidade de um modelo ser convertido em `ContentCardModel`.
///
/// Esse protocolo é adotado por modelos de alto nível como:
/// - `CharacterCardModel`
/// - `ComicCardModel`
/// - Futuramente: `EventCardModel`, `SeriesCardModel`, etc.
///
/// A ideia é fornecer uma interface comum para que todos os tipos de conteúdo
/// (personagens, HQs, séries, eventos) possam gerar uma representação visual
/// unificada dentro do DesignSystem.
///
/// - Atenção:
///   Cada modelo deve definir sua própria implementação de `toContentCardModel()`
///   para personalizar aspectos como imagem, proporção, conteúdo e badge.
///
public protocol ContentCardConvertible {
    /// Converte o modelo em um `ContentCardModel` compatível com o DesignSystem.
    func toContentCardModel() -> ContentCardModel
}

// MARK: - Extensões utilitárias padrão

public extension ContentCardConvertible {
    /// Cria um `BadgeModel` padrão usado nos cards do DesignSystem.
    ///
    /// - Parameters:
    ///   - icon: Nome do símbolo SF Symbol.
    ///   - text: Texto exibido ao lado do ícone.
    ///   - color: Cor do badge. O padrão é `.red`.
    ///
    /// - Returns: Um `ContentCardModel.BadgeModel` configurado.
    func defaultBadge(
        icon: String,
        text: String,
        color: Color = .red
    ) -> ContentCardModel.BadgeModel {
        ContentCardModel.BadgeModel(icon: icon, text: text, color: color)
    }
}
