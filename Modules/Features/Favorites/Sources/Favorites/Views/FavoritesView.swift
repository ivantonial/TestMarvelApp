//
//  FavoritesView.swift
//  Favorites
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct FavoritesView: View {
    // MARK: - Properties
    @StateObject private var viewModel: FavoritesViewModel
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false

    private let onCharacterSelected: ((Character) -> Void)?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Initialization
    public init(
        viewModel: FavoritesViewModel,
        onCharacterSelected: ((Character) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onCharacterSelected = onCharacterSelected
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if viewModel.hasFavorites {
                    searchBar
                }

                if viewModel.hasFavorites && !viewModel.isSelectionMode {
                    sortOptions
                }

                if viewModel.isSelectionMode {
                    selectionToolbar
                }

                if viewModel.isLoading {
                    LoadingComponent(message: "Loading favorites...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.hasFavorites {
                    favoritesGrid
                } else {
                    emptyStateView
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .alert("Delete Favorites", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.removeSelectedFavorites()
            }
        } message: {
            Text("Are you sure you want to remove \(viewModel.selectedCount) character(s) from favorites?")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(items: [viewModel.exportFavorites()])
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Favorites")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)

            if viewModel.hasFavorites {
                Text("\(viewModel.favoriteCharacters.count) Characters")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, viewModel.hasFavorites ? 10 : 20)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search favorites...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    // MARK: - Sort Options
    private var sortOptions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FavoritesSortOption.allCases, id: \.self) { option in
                    SortChipView(
                        title: option.title,
                        icon: option.icon,
                        isSelected: viewModel.sortOption == option,
                        action: { viewModel.updateSortOption(option) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }

    // MARK: - Selection Toolbar
    private var selectionToolbar: some View {
        HStack {
            Button(action: {
                if viewModel.isAllSelected {
                    viewModel.deselectAll()
                } else {
                    viewModel.selectAll()
                }
            }) {
                Text(viewModel.isAllSelected ? "Deselect All" : "Select All")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
            }

            Spacer()

            Text("\(viewModel.selectedCount) selected")
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                if viewModel.selectedCount > 0 {
                    showingDeleteAlert = true
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(viewModel.selectedCount > 0 ? .red : .gray)
            }
            .disabled(viewModel.selectedCount == 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.hasFavorites {
                Menu {
                    Button(action: {
                        viewModel.toggleSelectionMode()
                    }) {
                        Label(
                            viewModel.isSelectionMode ? "Done" : "Select",
                            systemImage: viewModel.isSelectionMode ? "checkmark.circle" : "checkmark.circle"
                        )
                    }

                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share List", systemImage: "square.and.arrow.up")
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Favorites Grid
    private var favoritesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredCharacters) { character in
                    FavoriteCardView(
                        character: character,
                        isSelected: viewModel.selectedCharacters.contains(character.id),
                        isSelectionMode: viewModel.isSelectionMode,
                        onTap: {
                            if viewModel.isSelectionMode {
                                viewModel.toggleSelection(for: character)
                            } else {
                                onCharacterSelected?(character)
                            }
                        },
                        onRemove: {
                            viewModel.removeFavorite(character)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Start adding your favorite Marvel characters")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
