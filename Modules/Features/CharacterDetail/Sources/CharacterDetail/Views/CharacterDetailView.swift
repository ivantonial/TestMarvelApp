//
//  CharacterDetailView.swift
//  CharacterDetail
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    @Environment(\.dismiss) private var dismiss
    private let onComicsSelected: (() -> Void)?

    public init(
        viewModel: CharacterDetailViewModel,
        onComicsSelected: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComicsSelected = onComicsSelected
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    CharacterDetailHeaderImageView(
                        imageURL: viewModel.detailModel.character.thumbnail.secureUrl
                    )

                    contentSection
                }
            }
            .ignoresSafeArea(edges: .top)

            CharacterDetailNavigationBarView(
                isFavorite: viewModel.isFavorite,
                onBack: { dismiss() },
                onToggleFavorite: { viewModel.toggleFavorite() }
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadCharacterDetails()
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Character Name
            Text(viewModel.detailModel.character.name)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Description
            if !viewModel.detailModel.character.description.isEmpty {
                CharacterDetailDescriptionView(
                    description: viewModel.detailModel.character.description
                )
            }

            // Stats Grid
            CharacterDetailStatsGridView(
                stats: viewModel.detailModel.stats
            )

            // Actions
            CharacterDetailActionsView(
                hasComics: viewModel.hasComics,
                comicsCount: viewModel.detailModel.character.comics.available,
                wikiURL: viewModel.detailModel.shareInfo.wikiURL,
                onComicsSelected: onComicsSelected
            )

            // Related Content
            if viewModel.hasRelatedContent {
                CharacterDetailRelatedContentView(
                    relatedContent: viewModel.detailModel.relatedContent
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, -40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black)
                .shadow(color: .red.opacity(0.3), radius: 20, x: 0, y: -10)
        )
    }
}

