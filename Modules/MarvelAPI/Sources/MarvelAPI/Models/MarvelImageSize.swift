//
//  MarvelImageSize.swift
//  MarvelAPI
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import Foundation

/// Tamanhos padrão de imagem da Marvel API
/// Documentação: https://developer.marvel.com/documentation/images
public enum MarvelImageSize: String, CaseIterable, Sendable {
    // Portrait sizes (aspect ratio 2:3)
    case portraitSmall = "portrait_small"           // 50x75px
    case portraitMedium = "portrait_medium"         // 100x150px
    case portraitXLarge = "portrait_xlarge"         // 150x225px
    case portraitFantastic = "portrait_fantastic"   // 168x252px
    case portraitUncanny = "portrait_uncanny"       // 300x450px
    case portraitIncredible = "portrait_incredible" // 216x324px

    // Standard sizes (square, aspect ratio 1:1)
    case standardSmall = "standard_small"           // 65x45px
    case standardMedium = "standard_medium"         // 100x100px
    case standardLarge = "standard_large"           // 140x140px
    case standardXLarge = "standard_xlarge"         // 200x200px
    case standardFantastic = "standard_fantastic"   // 250x250px
    case standardAmazing = "standard_amazing"       // 180x180px

    // Landscape sizes (aspect ratio 16:9)
    case landscapeSmall = "landscape_small"         // 120x90px
    case landscapeMedium = "landscape_medium"       // 175x130px
    case landscapeLarge = "landscape_large"         // 190x140px
    case landscapeXLarge = "landscape_xlarge"       // 270x200px
    case landscapeAmazing = "landscape_amazing"     // 250x156px
    case landscapeIncredible = "landscape_incredible" // 464x261px

    // Full size
    case full = "detail"                            // Full resolution

    /// Retorna as dimensões aproximadas para cada tamanho
    public var dimensions: (width: Int, height: Int) {
        switch self {
        // Portrait
        case .portraitSmall: return (50, 75)
        case .portraitMedium: return (100, 150)
        case .portraitXLarge: return (150, 225)
        case .portraitFantastic: return (168, 252)
        case .portraitUncanny: return (300, 450)
        case .portraitIncredible: return (216, 324)

        // Standard
        case .standardSmall: return (65, 45)
        case .standardMedium: return (100, 100)
        case .standardLarge: return (140, 140)
        case .standardXLarge: return (200, 200)
        case .standardFantastic: return (250, 250)
        case .standardAmazing: return (180, 180)

        // Landscape
        case .landscapeSmall: return (120, 90)
        case .landscapeMedium: return (175, 130)
        case .landscapeLarge: return (190, 140)
        case .landscapeXLarge: return (270, 200)
        case .landscapeAmazing: return (250, 156)
        case .landscapeIncredible: return (464, 261)

        // Full
        case .full: return (0, 0) // Dimensões variáveis
        }
    }

    /// Retorna o aspect ratio para cada categoria
    public var aspectRatio: CGFloat {
        switch self {
        case .portraitSmall, .portraitMedium, .portraitXLarge,
             .portraitFantastic, .portraitUncanny, .portraitIncredible:
            return 2.0 / 3.0

        case .standardSmall, .standardMedium, .standardLarge,
             .standardXLarge, .standardFantastic, .standardAmazing:
            return 1.0

        case .landscapeSmall, .landscapeMedium, .landscapeLarge,
             .landscapeXLarge, .landscapeAmazing, .landscapeIncredible:
            return 16.0 / 9.0

        case .full:
            return 0 // Aspect ratio variável
        }
    }

    /// Retorna o tamanho recomendado baseado no contexto de uso
    public static func recommendedSize(for context: ImageContext) -> MarvelImageSize {
        switch context {
        case .thumbnail:
            return .standardSmall
        case .listItem:
            return .standardMedium
        case .cardSmall:
            return .portraitMedium
        case .cardMedium:
            return .portraitXLarge
        case .cardLarge:
            return .portraitFantastic
        case .cardSquareSmall:
            return .standardSmall
        case .cardSquareMedium:
            return .standardMedium
        case .cardSquareLarge:
            return .standardXLarge
        case .heroImage:
            return .landscapeIncredible
        case .detailHeader:
            return .portraitUncanny
        case .fullScreen:
            return .full
        }
    }
}

/// Contextos de uso para imagens
public enum ImageContext: Sendable {
    case thumbnail
    case listItem
    case cardSmall
    case cardMedium
    case cardLarge
    case cardSquareSmall
    case cardSquareMedium
    case cardSquareLarge
    case heroImage
    case detailHeader
    case fullScreen
}

// MARK: - Extension para MarvelImage
extension MarvelImage {
    /// Gera a URL com o tamanho especificado
    public func url(size: MarvelImageSize) -> URL? {
        let securePath = path.replacingOccurrences(of: "http://", with: "https://")
        let sizeString = size == .full ? "" : "/\(size.rawValue)"
        return URL(string: "\(securePath)\(sizeString).\(self.extension)")
    }

    /// URL com tamanho recomendado para o contexto
    public func url(for context: ImageContext) -> URL? {
        url(size: MarvelImageSize.recommendedSize(for: context))
    }
}
