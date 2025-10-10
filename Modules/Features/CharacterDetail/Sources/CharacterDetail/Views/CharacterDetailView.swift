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
            // Background
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image Section
                    heroImageSection

                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Character Name
                        Text(viewModel.character.name)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Description
                        if !viewModel.character.description.isEmpty {
                            descriptionSection
                        }

                        // Stats Grid
                        statsGrid

                        // Actions
                        actionButtons

                        // Related Content
                        if viewModel.hasRelatedContent {
                            relatedContentSection
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
            .ignoresSafeArea(edges: .top)

            // Custom Navigation Bar
            customNavigationBar
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadCharacterDetails()
        }
    }

    // MARK: - Hero Image Section
    private var heroImageSection: some View {
        GeometryReader { geometry in
            AsyncImage(url: viewModel.character.thumbnail.secureUrl) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    }
                    .frame(height: 400)

                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 400)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0),
                                    Color.black.opacity(0.3),
                                    Color.black.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 400)

                @unknown default:
                    Color.gray.opacity(0.2)
                        .frame(height: 400)
                }
            }
        }
        .frame(height: 400)
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.red)
                .tracking(2)

            Text(viewModel.character.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "book.fill",
                title: "Comics",
                value: "\(viewModel.character.comics.available)",
                color: .red
            )

            StatCard(
                icon: "tv.fill",
                title: "Series",
                value: "\(viewModel.character.series.available)",
                color: .blue
            )

            StatCard(
                icon: "star.fill",
                title: "Stories",
                value: "\(viewModel.character.stories.available)",
                color: .yellow
            )

            StatCard(
                icon: "calendar",
                title: "Events",
                value: "\(viewModel.character.events.available)",
                color: .green
            )
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if viewModel.character.comics.available > 0 {
                PrimaryButtonComponent(
                    title: "View Comics (\(viewModel.character.comics.available))",
                    action: {
                        onComicsSelected?()
                    }
                )
            }

            if let wikiURL = viewModel.wikiURL {
                Link(destination: wikiURL) {
                    HStack {
                        Image(systemName: "globe")
                        Text("View on Marvel Wiki")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Related Content Section
    private var relatedContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("APPEARS IN")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.red)
                .tracking(2)

            if !viewModel.recentComics.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Comics")
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(viewModel.recentComics.prefix(3), id: \.name) { comic in
                        HStack {
                            Image(systemName: "book.circle.fill")
                                .foregroundColor(.red.opacity(0.7))

                            Text(comic.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)

                            Spacer()
                        }
                    }
                }
            }

            if !viewModel.recentSeries.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Series")
                        .font(.headline)
                        .foregroundColor(.white)

                    ForEach(viewModel.recentSeries.prefix(3), id: \.name) { series in
                        HStack {
                            Image(systemName: "tv.circle.fill")
                                .foregroundColor(.blue.opacity(0.7))

                            Text(series.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)

                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }

    // MARK: - Custom Navigation Bar
    private var customNavigationBar: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
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

                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(viewModel.isFavorite ? .red : .white)
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

// MARK: - Supporting Views
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
