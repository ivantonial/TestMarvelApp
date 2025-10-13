//
//  CharacterDetailNavigationBarView.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 10/10/25.
//

import SwiftUI

struct CharacterDetailNavigationBarView: View {
    let isFavorite: Bool
    let onBack: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .blur(radius: 1)
                        )
                }

                Spacer()

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isFavorite ? .red : .white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .blur(radius: 1)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)

            Spacer()
        }
    }
}
