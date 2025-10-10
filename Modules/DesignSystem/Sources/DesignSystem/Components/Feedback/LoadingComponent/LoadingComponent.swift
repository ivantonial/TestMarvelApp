//
//  LoadingComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI

public struct LoadingComponent: View {
    public let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                .scaleEffect(1.5)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}
