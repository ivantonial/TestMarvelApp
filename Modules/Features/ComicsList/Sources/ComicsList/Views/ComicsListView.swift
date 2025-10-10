//
//  ComicsListView.swift
//  ComicsList
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct ComicsListView: View {
    @StateObject private var viewModel: ComicsListViewModel
    @Environment(\.dismiss) private var dismiss

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public init(viewModel: ComicsListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Content
                if viewModel.isLoading && viewModel.comics.isEmpty {
                    Spacer()
                    LoadingComponent(message: "Loading comics...")
                    Spacer()
                } else if let error = viewModel.error, viewModel.comics.isEmpty {
                    Spacer()
                    ErrorComponent(
                        message: error.localizedDescription,
                        retryAction: viewModel.refresh
                    )
                    Spacer()
                } else if viewModel.comics.isEmpty {
                    emptyStateView
                } else {
                    comicsGrid
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.comics.isEmpty {
                viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }

                Spacer()

                if viewModel.totalComics > 0 {
                    Text("\(viewModel.totalComics) Comics")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 10)

            VStack(spacing: 8) {
                Text(viewModel.character.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Comics Collection")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            // Filter Pills
            if viewModel.hasFilters {
                filterPills
            }
        }
        .background(Color.black)
    }

    // MARK: - Filter Pills
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ComicFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.title,
                        isSelected: viewModel.selectedFilter == filter,
                        action: {
                            viewModel.selectFilter(filter)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Comics Grid
    private var comicsGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(viewModel.filteredComics) { comic in
                    ComicCardView(comic: comic)
                        .onTapGesture {
                            viewModel.selectComic(comic)
                        }
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentComic: comic)
                        }
                }

                if viewModel.isLoading && !viewModel.comics.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .gridCellColumns(2)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .refreshable {
            await refreshData()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Comics Available")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("This character doesn't have any comics yet.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    private func refreshData() async {
        viewModel.refresh()
    }
}

// MARK: - Comic Card View
struct ComicCardView: View {
    let comic: Comic

    var body: some View {
        VStack(spacing: 0) {
            // Comic Cover
            AsyncImage(url: comic.thumbnail.secureUrl) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    }
                    .aspectRatio(0.77, contentMode: .fit)

                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(0.77, contentMode: .fit)
                        .clipped()

                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                    .aspectRatio(0.77, contentMode: .fit)

                @unknown default:
                    Color.gray.opacity(0.2)
                        .aspectRatio(0.77, contentMode: .fit)
                }
            }

            // Comic Info
            VStack(alignment: .leading, spacing: 4) {
                Text(comic.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                if let description = comic.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
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

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.red : Color.white.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.red.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
