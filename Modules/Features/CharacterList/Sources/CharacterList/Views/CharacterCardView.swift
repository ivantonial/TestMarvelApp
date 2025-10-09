//
//  CharacterCardView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import DesignSystem
import MarvelAPI
import SwiftUI

struct CharacterCardView: View {
    let model: CharacterCardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Character Image com tamanho fixo
            GeometryReader { geometry in
                AsyncImage(url: model.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                    case .failure:
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)

            // Character Info com altura fixa
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(.red)

                    Text("\(model.comicsCount) comics")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
            .background(Color.black.opacity(0.8))
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .red.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
