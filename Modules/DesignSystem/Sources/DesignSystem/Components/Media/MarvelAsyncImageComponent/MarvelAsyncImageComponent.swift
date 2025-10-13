//
//  MarvelAsyncImageComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import DesignSystem
import SwiftUI
import MarvelAPI

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

        // Caso a imagem padrão "not found"
        if securePath.contains("image_not_available") {
            return URL(string: "\(securePath)/\(MarvelImageSize.standardXLarge.rawValue).\(img.extension)")
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
                        withAnimation(.easeIn(duration: 0.3)) {
                            isImageLoaded = true
                        }
                    }

            case .failure:
                ZStack {
                    placeholderBackground
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: iconSize * 0.8))
                            .foregroundColor(.red.opacity(0.8))

                        retryButton
                            .padding(.horizontal, 20)
                    }
                }
                .cornerRadius(cornerRadius)

            @unknown default:
                placeholderView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isImageLoaded)
    }

    // MARK: - Loading View
    @ViewBuilder
    private var loadingView: some View {
        ZStack {
            placeholderBackground

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                .scaleEffect(0.8)
        }
        .cornerRadius(cornerRadius)
    }

    // MARK: - Placeholder View
    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            placeholderBackground

            Image(systemName: iconForContext)
                .font(.system(size: iconSize))
                .foregroundColor(.gray.opacity(0.5))
        }
        .cornerRadius(cornerRadius)
    }

    // MARK: - Error View
    @ViewBuilder
    private var errorView: some View {
        ZStack {
            placeholderBackground

            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: iconSize * 0.8))
                    .foregroundColor(.red.opacity(0.6))

                if imageContext == .heroImage || imageContext == .fullScreen {
                    Text("Failed to load")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .cornerRadius(cornerRadius)
    }

    // MARK: - Helper Views
    private var placeholderBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    // MARK: - Retry Button
    @ViewBuilder
    private var retryButton: some View {
        PrimaryButtonComponent(title: "Tentar novamente") {
            withAnimation(.easeInOut(duration: 0.25)) {
                hasError = false
                isImageLoaded = false
            }
        }
        .frame(maxWidth: 160, maxHeight: 40)
    }

    // MARK: - Helper Properties
    private var iconForContext: String {
        switch imageContext {
        case .thumbnail, .listItem:
            return "person.circle.fill"
        case .cardSmall, .cardMedium, .cardLarge, .cardSquareSmall, .cardSquareMedium, .cardSquareLarge:
            return "photo"
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

    /// Inicializador para cards
    static func card(
        _ marvelImage: MarvelImage?,
        size: CardSize = .medium,
        cornerRadius: CGFloat = 0
    ) -> MarvelAsyncImageComponent {
        let context: ImageContext = {
            switch size {
            case .small: return .cardSmall
            case .medium: return .cardMedium
            case .large: return .cardLarge
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

    static var previews: some View {
        VStack(spacing: 20) {
            // Thumbnail
            MarvelAsyncImageComponent.thumbnail(sampleImage)
                .frame(width: 50, height: 50)

            // Card Small
            MarvelAsyncImageComponent.card(sampleImage, size: .small)
                .frame(width: 100, height: 150)

            // Card Medium
            MarvelAsyncImageComponent.card(sampleImage, size: .medium)
                .frame(width: 150, height: 225)

            // Header
            MarvelAsyncImageComponent.header(sampleImage)
                .frame(height: 300)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
