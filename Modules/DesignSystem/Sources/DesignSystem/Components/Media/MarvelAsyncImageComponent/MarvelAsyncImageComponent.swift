//
//  MarvelAsyncImageComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import DesignSystem
import MarvelAPI
import SwiftUI

/// Componente otimizado para carregar imagens da Marvel API com tamanhos apropriados
public struct MarvelAsyncImageComponent: View {
    // MARK: - Properties
    private let marvelImage: MarvelImage?
    private let imageContext: ImageContext
    private let contentMode: ContentMode
    private let cornerRadius: CGFloat
    private let showLoadingIndicator: Bool

    @State private var isImageLoaded = false
    @State private var hasError = false
    @State private var retryCount = 0
    @State private var autoRetryAttempts = 0

    // Configuração de retry
    private let maxAutoRetries = 3
    private let retryDelay: TimeInterval = 1.0

    // Cache de tamanhos para evitar recálculo
    private var imageSize: MarvelImageSize {
        MarvelImageSize.recommendedSize(for: imageContext)
    }

    private var imageURL: URL? {
        guard let img = marvelImage else { return nil }

        // Sanitiza o caminho para HTTPS e remove duplicidades
        var securePath = img.path
            .replacingOccurrences(of: "http://", with: "https://")
            .replacingOccurrences(of: "https://https://", with: "https://")

        // Evita casos de path vazio
        guard !securePath.isEmpty else { return nil }

        // Caso a imagem padrão "not found" - ajusta tamanho baseado no contexto
        if securePath.contains("image_not_available") {
            // Para contextos de card portrait (comics), usa tamanho portrait
            switch imageContext {
            case .cardSmall, .cardMedium, .cardLarge, .detailHeader:
                // Para comics e contextos portrait, usa portrait_uncanny
                return URL(string: "\(securePath)/portrait_uncanny.\(img.extension)")
            case .cardSquareSmall, .cardSquareMedium, .cardSquareLarge, .thumbnail, .listItem:
                // Para contextos quadrados (characters), usa standard
                return URL(string: "\(securePath)/standard_xlarge.\(img.extension)")
            case .heroImage:
                // Para hero images, usa landscape
                return URL(string: "\(securePath)/landscape_incredible.\(img.extension)")
            case .fullScreen:
                // Para fullscreen, usa o tamanho completo
                return URL(string: "\(securePath).\(img.extension)")
            }
        }

        // Tenta com tamanho recomendado
        if let url = img.url(size: MarvelImageSize.recommendedSize(for: imageContext)) {
            return url
        }

        // Fallback comum para personagens
        if let fallback = URL(string: "\(securePath)/\(MarvelImageSize.standardFantastic.rawValue).\(img.extension)") {
            return fallback
        }

        // Último fallback — usa o secureUrl direto
        return img.secureUrl
    }

    // MARK: - Initialization
    public init(
        marvelImage: MarvelImage?,
        context: ImageContext = .cardMedium,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0,
        showLoadingIndicator: Bool = true
    ) {
        self.marvelImage = marvelImage
        self.imageContext = context
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.showLoadingIndicator = showLoadingIndicator
    }

    // MARK: - Body
    public var body: some View {
        // Usa ID único para forçar recarregamento quando retryCount muda
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                if showLoadingIndicator {
                    loadingView
                } else {
                    placeholderView
                }

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
                    .onAppear {
                        isImageLoaded = true
                        hasError = false
                        autoRetryAttempts = 0
                    }

            case .failure:
                if autoRetryAttempts < maxAutoRetries {
                    loadingView
                        .onAppear {
                            scheduleAutoRetry()
                        }
                } else {
                    errorView
                        .onTapGesture {
                            performManualRetry()
                        }
                }

            @unknown default:
                placeholderView
            }
        }
        .id("\(marvelImage?.path ?? "")-\(retryCount)")  // Força reload quando retryCount muda
    }

    // MARK: - Retry Logic
    private func scheduleAutoRetry() {
        guard autoRetryAttempts < maxAutoRetries else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
            autoRetryAttempts += 1
            retryCount += 1
        }
    }

    private func performManualRetry() {
        autoRetryAttempts = 0
        retryCount += 1
    }

    // MARK: - View Components
    private var loadingView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ProgressView()
                .tint(.red)
                .scaleEffect(0.8)
        }
    }

    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: iconForContext)
                .font(.system(size: iconSize))
                .foregroundColor(Color.gray.opacity(0.5))
        }
    }

    private var errorView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.red.opacity(0.2),
                            Color.red.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: iconSize * 0.8))
                    .foregroundColor(.red.opacity(0.7))

                Text("Tap to retry")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helper Properties
    private var iconForContext: String {
        switch imageContext {
        case .thumbnail, .listItem:
            return "person.circle.fill"
        case .cardSmall, .cardMedium, .cardLarge:
            // Específico para comics (portrait)
            return "book.closed.fill"
        case .cardSquareSmall, .cardSquareMedium, .cardSquareLarge:
            // Específico para characters (square)
            return "person.crop.square.fill"
        case .heroImage, .detailHeader:
            return "photo.fill"
        case .fullScreen:
            return "photo.fill.on.rectangle.fill"
        }
    }

    private var iconSize: CGFloat {
        switch imageContext {
        case .thumbnail:
            return 20
        case .listItem:
            return 24
        case .cardSmall, .cardSquareSmall:
            return 30
        case .cardMedium, .cardSquareMedium:
            return 40
        case .cardLarge, .cardSquareLarge:
            return 50
        case .heroImage, .detailHeader:
            return 60
        case .fullScreen:
            return 80
        }
    }
}

// MARK: - Convenience Initializers
public extension MarvelAsyncImageComponent {
    /// Inicializador para thumbnails pequenos
    static func thumbnail(
        _ marvelImage: MarvelImage?,
        cornerRadius: CGFloat = 8
    ) -> MarvelAsyncImageComponent {
        MarvelAsyncImageComponent(
            marvelImage: marvelImage,
            context: .thumbnail,
            cornerRadius: cornerRadius
        )
    }

    /// Inicializador para cards com detecção de tipo
    static func card(
        _ marvelImage: MarvelImage?,
        size: CardSize = .medium,
        isPortrait: Bool = false,
        cornerRadius: CGFloat = 0
    ) -> MarvelAsyncImageComponent {
        let context: ImageContext = {
            if isPortrait {
                // Para comics e outros cards portrait
                switch size {
                case .small: return .cardSmall
                case .medium: return .cardMedium
                case .large: return .cardLarge
                }
            } else {
                // Para characters e outros cards quadrados
                switch size {
                case .small: return .cardSquareSmall
                case .medium: return .cardSquareMedium
                case .large: return .cardSquareLarge
                }
            }
        }()

        return MarvelAsyncImageComponent(
            marvelImage: marvelImage,
            context: context,
            cornerRadius: cornerRadius
        )
    }

    /// Inicializador para imagem de cabeçalho
    static func header(
        _ marvelImage: MarvelImage?
    ) -> MarvelAsyncImageComponent {
        MarvelAsyncImageComponent(
            marvelImage: marvelImage,
            context: .detailHeader,
            contentMode: .fill
        )
    }

    enum CardSize {
        case small, medium, large
    }
}

// MARK: - Preview Provider
#if DEBUG
struct MarvelAsyncImageComponent_Previews: PreviewProvider {
    static let sampleImage = MarvelImage(
        path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784",
        extension: "jpg"
    )

    static let notFoundImage = MarvelImage(
        path: "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available",
        extension: "jpg"
    )

    static var previews: some View {
        VStack(spacing: 20) {
            Text("Normal Images")
                .font(.headline)

            HStack(spacing: 10) {
                // Thumbnail
                MarvelAsyncImageComponent.thumbnail(sampleImage)
                    .frame(width: 50, height: 50)

                // Card Small Square
                MarvelAsyncImageComponent.card(sampleImage, size: .small)
                    .frame(width: 100, height: 100)

                // Card Small Portrait
                MarvelAsyncImageComponent.card(sampleImage, size: .small, isPortrait: true)
                    .frame(width: 100, height: 150)
            }

            Text("Not Found Images")
                .font(.headline)
                .padding(.top)

            HStack(spacing: 10) {
                // Not Found Square (Character)
                MarvelAsyncImageComponent.card(notFoundImage, size: .medium)
                    .frame(width: 150, height: 150)

                // Not Found Portrait (Comic)
                MarvelAsyncImageComponent.card(notFoundImage, size: .medium, isPortrait: true)
                    .frame(width: 150, height: 225)
            }

            // Header
            MarvelAsyncImageComponent.header(notFoundImage)
                .frame(height: 300)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
