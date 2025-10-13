//
//  FavoritesCardView.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

//import MarvelAPI
//import SwiftUI
//
//public struct FavoriteCardView: View {
//    public let character: Character
//    public let isSelected: Bool
//    public let isSelectionMode: Bool
//    public let onTap: () -> Void
//    public let onRemove: () -> Void
//
//    @State private var isPressed = false
//
//    public var body: some View {
//        VStack(spacing: 0) {
//            ZStack(alignment: .topTrailing) {
//                AsyncImage(url: character.thumbnail.secureUrl) { phase in
//                    switch phase {
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(height: 200)
//                            .clipped()
//                    default:
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.2))
//                            .frame(height: 200)
//                            .overlay(
//                                Image(systemName: "photo")
//                                    .font(.system(size: 40))
//                                    .foregroundColor(.gray)
//                            )
//                    }
//                }
//
//                if isSelectionMode {
//                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                        .font(.system(size: 24))
//                        .foregroundColor(isSelected ? .red : .white)
//                        .background(Circle().fill(Color.black.opacity(0.5)))
//                        .padding(8)
//                } else {
//                    Button(action: onRemove) {
//                        Image(systemName: "heart.fill")
//                            .font(.system(size: 20))
//                            .foregroundColor(.red)
//                            .padding(8)
//                            .background(Circle().fill(Color.black.opacity(0.6)))
//                    }
//                    .padding(8)
//                }
//            }
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(character.name)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                    .lineLimit(2)
//                    .minimumScaleFactor(0.9)
//
//                HStack(spacing: 8) {
//                    Label("\(character.comics.available)", systemImage: "book.fill")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//
//                    Label("\(character.series.available)", systemImage: "tv.fill")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(10)
//            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .background(Color.black.opacity(0.8))
//        }
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(
//                    isSelected ? Color.red : Color.red.opacity(0.3),
//                    lineWidth: isSelected ? 2 : 1
//                )
//        )
//        .scaleEffect(isPressed ? 0.95 : 1.0)
//        .onTapGesture {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                isPressed = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                    isPressed = false
//                }
//                onTap()
//            }
//        }
//    }
//}
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
