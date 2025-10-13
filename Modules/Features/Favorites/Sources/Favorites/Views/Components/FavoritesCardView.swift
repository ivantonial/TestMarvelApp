//
//  FavoritesCardView.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import DesignSystem
import MarvelAPI
import SwiftUI

public struct FavoriteCardView: View {
    public let character: Character
    public let isSelected: Bool
    public let isSelectionMode: Bool
    public let onTap: () -> Void
    public let onRemove: () -> Void

    @State private var isPressed = false

    public var body: some View {
        ZStack {
            ContentCardComponent(
                model: character.toContentCardModel(),
                onTap: onTap
            )

            // Overlay de seleção/favorito
            VStack {
                HStack {
                    Spacer()

                    if isSelectionMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .red : .white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                            .padding(8)
                    } else {
                        Button(action: onRemove) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(8)
                    }
                }
                Spacer()
            }
        }
        .overlay(
            isSelected ?
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red, lineWidth: 2)
            : nil
        )
    }
}

// MARK: - Character Extension
private extension Character {
    func toContentCardModel() -> ContentCardModel {
        ContentCardModel(
            id: id,
            title: name,
            subtitle: nil,
            imageURL: thumbnail.secureUrl,
            aspectRatio: 1.0,
            badge: ContentCardModel.BadgeModel(
                icon: "book.fill",
                text: "\(comics.available) comics",
                color: .gray
            )
        )
    }
}
