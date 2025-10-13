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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // Adaptação para portrait/landscape
    private var gridColumns: [GridItem] {
        let isLandscape = verticalSizeClass == .compact
        let isPad = horizontalSizeClass == .regular && verticalSizeClass == .regular

        if isLandscape {
            // 4 colunas em landscape
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
        } else if isPad {
            // 3 colunas no iPad
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        } else {
            // 2 colunas em portrait
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        }
    }

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
                    FilterPillComponent(
                        title: filter.title,
                        isSelected: viewModel.selectedFilter == filter,
                        style: .primary,
                        selectedColor: .red,
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

    // MARK: - Comics Grid usando ContentCardComponent
    private var comicsGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(viewModel.filteredComics) { comic in
                    ContentCardComponent(
                        model: ComicCardModel(from: comic).toContentCardModel(),
                        onTap: {
                            viewModel.selectComic(comic)
                        }
                    )
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentComic: comic)
                    }
                }

                if viewModel.isLoading && !viewModel.comics.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .gridCellColumns(gridColumns.count)
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
