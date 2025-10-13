//
//  SettingsSectionHeaderView.swift
//  Settings
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import DesignSystem
import SwiftUI

/// View reutilizável para cabeçalhos de seção no SettingsView.
/// Pode ser usada em qualquer Section, garantindo consistência visual.
public struct SettingsSectionHeaderView: View {
    // MARK: - Properties
    public let title: String
    public let systemImage: String?
    public let color: Color

    // MARK: - Inicialização
    public init(
        title: String,
        systemImage: String? = nil,
        color: Color = .gray
    ) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(title.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
                .tracking(0.8)

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background(Color.clear)
        .accessibilityAddTraits(.isHeader)
    }
}
