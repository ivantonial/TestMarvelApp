//
//  ErrorComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI

public struct ErrorComponent: View {
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

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let retryAction {
                PrimaryButtonComponent(
                    title: "Tentar Novamente",
                    action: retryAction
                )
                .padding(.horizontal)
            }
        }
        .padding()
    }
}
