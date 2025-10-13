//
//  ContentCardComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 13/10/25.
//

import SwiftUI

// MARK: - Card Configuration Model
public struct ContentCardModel: Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String?
    public let imageURL: URL?
    public let aspectRatio: CGFloat
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

    public init(
        id: Int,
        title: String,
        subtitle: String? = nil,
        imageURL: URL?,
        aspectRatio: CGFloat = 1.0,
        badge: BadgeModel? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.aspectRatio = aspectRatio
        self.badge = badge
    }
}

// MARK: - Content Card Component
public struct ContentCardComponent: View {
    private let model: ContentCardModel
    private let onTap: (() -> Void)?

    @State private var isPressed = false

    public init(
        model: ContentCardModel,
        onTap: (() -> Void)? = nil
    ) {
        self.model = model
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Image Section
            cardImage

            // Info Section
            cardInfo
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .red.opacity(0.2), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - Image View
    private var cardImage: some View {
        GeometryReader { geometry in
            AsyncImage(url: model.imageURL) { phase in
                switch phase {
                case .empty:
                    loadingView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width / model.aspectRatio
                        )
                        .clipped()
                case .failure:
                    errorView
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
        }
        .aspectRatio(model.aspectRatio, contentMode: .fit)
    }

    private var loadingView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
        }
    }

    private var errorView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Info View
    private var cardInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(model.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            // Subtitle or Badge
            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            } else if let badge = model.badge {
                HStack(spacing: 4) {
                    Image(systemName: badge.icon)
                        .font(.caption)
                        .foregroundColor(badge.color)

                    Text(badge.text)
                        .font(.caption)
                        .foregroundColor(badge.color)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Actions
    private func handleTap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
            onTap?()
        }
    }
}

// MARK: - Style Modifier
public struct ContentCardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderOpacity: Double
    let shadowColor: Color
    let shadowOpacity: Double

    public init(
        cornerRadius: CGFloat = 12,
        borderColor: Color = .red,
        borderOpacity: Double = 0.3,
        shadowColor: Color = .red,
        shadowOpacity: Double = 0.2
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderOpacity = borderOpacity
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
    }

    public func body(content: Content) -> some View {
        content
            .background(Color.gray.opacity(0.2))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(borderOpacity), lineWidth: 1)
            )
            .shadow(color: shadowColor.opacity(shadowOpacity), radius: 5, x: 0, y: 2)
    }
}

public extension View {
    func contentCardStyle(_ style: ContentCardStyle = ContentCardStyle()) -> some View {
        modifier(style)
    }
}
