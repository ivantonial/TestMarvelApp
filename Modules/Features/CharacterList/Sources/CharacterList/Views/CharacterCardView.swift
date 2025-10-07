//
//  CharacterCardView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI
import MarvelAPI
import DesignSystem

struct CharacterCardView: View {
    let model: CharacterCardModel

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Imagem
            AsyncImage(url: model.imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.15)
                        ProgressView().tint(.red)
                    }
                    .frame(height: 180)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                        .clipped()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                    .frame(height: 180)
                @unknown default:
                    EmptyView()
                }
            }

            // MARK: - Info
            VStack(alignment: .leading, spacing: 6) {
                Text(model.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("\(model.comicsCount) comics")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
        }
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
