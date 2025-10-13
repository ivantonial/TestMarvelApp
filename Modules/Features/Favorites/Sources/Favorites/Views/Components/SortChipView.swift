//
//  SortChipView.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import SwiftUI

public struct SortChipView: View {
    public let title: String
    public let icon: String
    public let isSelected: Bool
    public let action: () -> Void

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2)
                Text(title).font(.caption2)
            }
            .foregroundColor(isSelected ? .red : .gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
