//
//  PrimaryButtonView.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI
import Core

// MARK: - Primary Button
public struct PrimaryButtonView: View {
    let model: PrimaryButtonModel

    public init(model: PrimaryButtonModel) {
        self.model = model
    }

    public var body: some View {
        Button(action: model.action) {
            Text(model.title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(model.isEnabled ? Color.red : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!model.isEnabled)
    }
}

public struct PrimaryButtonModel {
    public let title: String
    public let isEnabled: Bool
    public let action: () -> Void

    public init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
}

// MARK: - Loading View
public struct LoadingView: View {
    let model: LoadingViewModel

    public init(model: LoadingViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                .scaleEffect(1.5)

            if let message = model.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}

public struct LoadingViewModel {
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }
}

// MARK: - Error View
public struct ErrorView: View {
    let model: ErrorViewModel

    public init(model: ErrorViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text(model.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(model.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let retryAction = model.retryAction {
                PrimaryButtonView(
                    model: PrimaryButtonModel(
                        title: "Tentar Novamente",
                        action: retryAction
                    )
                )
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

public struct ErrorViewModel {
    public let title: String
    public let message: String
    public let retryAction: (() -> Void)?

    public init(title: String = "Erro",
                message: String,
                retryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }
}

// MARK: - Async Image View
public struct AsyncImageView: View {
    let model: AsyncImageModel

    public init(model: AsyncImageModel) {
        self.model = model
    }

    public var body: some View {
        AsyncImage(url: model.url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: model.width, height: model.height)
                    .background(Color.gray.opacity(0.1))

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: model.contentMode)
                    .frame(width: model.width, height: model.height)

            case .failure:
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .frame(width: model.width, height: model.height)
                    .background(Color.gray.opacity(0.1))

            @unknown default:
                EmptyView()
            }
        }
        .cornerRadius(model.cornerRadius)
    }
}

public struct AsyncImageModel {
    public let url: URL?
    public let width: CGFloat?
    public let height: CGFloat?
    public let contentMode: ContentMode
    public let cornerRadius: CGFloat

    public init(url: URL?,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                contentMode: ContentMode = .fit,
                cornerRadius: CGFloat = 0) {
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }
}
