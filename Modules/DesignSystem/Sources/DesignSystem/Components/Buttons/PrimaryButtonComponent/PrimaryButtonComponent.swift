//
//  PrimaryButtonComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI

public struct PrimaryButtonComponent: View {
    public let title: String
    public let isEnabled: Bool
    public let action: () -> Void

    public init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.red : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}
