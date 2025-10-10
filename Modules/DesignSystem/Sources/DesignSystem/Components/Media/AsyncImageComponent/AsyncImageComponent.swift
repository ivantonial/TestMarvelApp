//
//  AsyncImageComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI

public struct AsyncImageComponent: View {
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

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: width, height: height)
                    .background(Color.gray.opacity(0.1))

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: width, height: height)

            case .failure:
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .frame(width: width, height: height)
                    .background(Color.gray.opacity(0.1))

            @unknown default:
                EmptyView()
            }
        }
        .cornerRadius(cornerRadius)
    }
}
