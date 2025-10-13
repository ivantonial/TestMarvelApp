//
//  FilterPillComponent.swift
//  DesignSystem
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI

/// Estilo visual do FilterPill
public enum FilterPillStyle {
    case primary    // Fundo preenchido quando selecionado
    case outlined   // Apenas borda
    case minimal    // Sem borda, apenas mudança de cor
}

/// Componente de filtro em formato pill reutilizável
public struct FilterPillComponent: View {
    // MARK: - Properties
    public let title: String
    public let icon: String?
    public let isSelected: Bool
    public let style: FilterPillStyle
    public let selectedColor: Color
    public let action: () -> Void

    // MARK: - Initialization
    public init(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        style: FilterPillStyle = .primary,
        selectedColor: Color = .red,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.style = style
        self.selectedColor = selectedColor
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundView)
            .overlay(overlayView)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Computed Properties
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return isSelected ? .black : .white
        case .outlined, .minimal:
            return isSelected ? selectedColor : .gray
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Capsule()
                .fill(isSelected ? selectedColor : Color.white.opacity(0.1))
        case .outlined:
            Capsule()
                .fill(Color.clear)
        case .minimal:
            Color.clear
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .primary:
            EmptyView()
        case .outlined:
            Capsule()
                .stroke(
                    isSelected ? selectedColor : Color.gray.opacity(0.3),
                    lineWidth: 1
                )
        case .minimal:
            EmptyView()
        }
    }
}
