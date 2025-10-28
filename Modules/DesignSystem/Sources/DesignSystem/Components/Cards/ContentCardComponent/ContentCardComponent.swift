//
//  ContentCardComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import MarvelAPI
import SwiftUI

// MARK: - Card Configuration Model
public struct ContentCardModel: Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String?
    public let imageURL: URL?
    public let marvelImage: MarvelImage?
    public let aspectRatio: CGFloat
    public let contentMode: ContentMode
    public let badge: BadgeModel?

    public struct BadgeModel {
        public let icon: String
        public let text: String
        public let color: Color

        public init(icon: String, text: String, color: Color = .gray) {
            self.icon = icon
            self.text = text
            self.color = color
        }
    }

    // MARK: - Initializers
    public init(
        id: Int,
        title: String,
        subtitle: String? = nil,
        imageURL: URL?,
        aspectRatio: CGFloat = 1.0,
        contentMode: ContentMode = .fill,
        badge: BadgeModel? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.marvelImage = nil
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.badge = badge
    }

    public init(
        id: Int,
        title: String,
        subtitle: String? = nil,
        marvelImage: MarvelImage?,
        aspectRatio: CGFloat = 1.0,
        contentMode: ContentMode = .fill,
        badge: BadgeModel? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = nil
        self.marvelImage = marvelImage
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.badge = badge
    }
}

// MARK: - Content Card Component
public struct ContentCardComponent: View {
    private let model: ContentCardModel
    private let onTap: (() -> Void)?

    @State private var isPressed = false
    @State private var retryCount = 0  // Para forçar reload das imagens

    public init(model: ContentCardModel, onTap: (() -> Void)? = nil) {
        self.model = model
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Container da imagem com proporção fixa
            imageContainer
                .aspectRatio(model.aspectRatio, contentMode: .fit)
                .clipped()
                .cornerRadius(12, corners: [.topLeft, .topRight])

            cardInfo
        }
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .red.opacity(0.2), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            animateTap {
                onTap?()
            }
        }
    }

    // MARK: - Image Container
    @ViewBuilder
    private var imageContainer: some View {
        ZStack {
            // Background sempre presente para manter proporção
            placeholderBackground

            // Conteúdo da imagem
            if let marvelImage = model.marvelImage {
                MarvelAsyncImageComponent(
                    marvelImage: marvelImage,
                    context: determineImageContext(),
                    contentMode: model.contentMode,
                    cornerRadius: 0
                )
            } else if let imageURL = model.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: model.contentMode)
                    case .failure:
                        errorViewWithRetry
                    @unknown default:
                        errorView
                    }
                }
                .id(retryCount)
            } else {
                // No image available
                errorView
            }
        }
    }

    // MARK: - Context Detection
    private func determineImageContext() -> ImageContext {
        // Detecta o tipo de card baseado no aspect ratio
        switch model.aspectRatio {
        case 0.6...0.8:  // Portrait (comics) - ~0.67
            // Retorna contexto de card portrait
            return .cardMedium
        case 0.9...1.1:  // Square (characters) - 1.0
            // Retorna contexto de card quadrado
            return .cardSquareMedium
        case 1.5...2.0:  // Landscape
            return .heroImage
        default:
            return .cardMedium
        }
    }

    // MARK: - Helpers
    private func animateTap(_ action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
            action()
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        ZStack {
            placeholderBackground

            ProgressView()
                .tint(.red)
                .scaleEffect(0.8)
        }
    }

    // MARK: - Error Views
    private var errorView: some View {
        ZStack {
            placeholderBackground

            Image(systemName: placeholderIcon)
                .font(.system(size: placeholderIconSize))
                .foregroundColor(.gray.opacity(0.5))
        }
    }

    private var errorViewWithRetry: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.red.opacity(0.2),
                    Color.red.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: placeholderIconSize * 0.8))
                    .foregroundColor(.red.opacity(0.7))

                Text("Tap to retry")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            retryCount += 1
        }
    }

    private var placeholderBackground: some View {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var placeholderIcon: String {
        // Choose icon based on aspect ratio
        switch model.aspectRatio {
        case 0.6...0.8: return "book.closed.fill"  // Comics (portrait ~0.67)
        case 0.9...1.1: return "person.crop.square.fill"  // Characters (square 1.0)
        default: return "photo"
        }
    }

    private var placeholderIconSize: CGFloat {
        // Adjust icon size based on aspect ratio
        switch model.aspectRatio {
        case 0.6...0.8: return 40  // Taller cards (comics)
        case 0.9...1.1: return 36  // Square cards (characters)
        default: return 32
        }
    }

    // MARK: - Info Section
    private var cardInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            if let subtitle = model.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            } else if let badge = model.badge {
                HStack(spacing: 4) {
                    Image(systemName: badge.icon)
                        .font(.system(size: 10, weight: .medium))

                    Text(badge.text)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(badge.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(badge.color.opacity(0.2))
                .cornerRadius(4)
            }

            if model.badge != nil && model.subtitle != nil {
                HStack(spacing: 4) {
                    Image(systemName: model.badge!.icon)
                        .font(.system(size: 10, weight: .medium))

                    Text(model.badge!.text)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(model.badge!.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(model.badge!.color.opacity(0.2))
                .cornerRadius(4)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
