//
//  SearchView.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFieldFocused: Bool
    private let onCharacterSelected: ((Character) -> Void)?

    public init(
        viewModel: SearchViewModel,
        onCharacterSelected: ((Character) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onCharacterSelected = onCharacterSelected
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Header
                searchHeader

                // Filter Pills
                if viewModel.hasResults {
                    filterSection
                }

                // Main Content
                if viewModel.isSearching {
                    loadingView
                } else if viewModel.hasResults {
                    searchResultsView
                } else if !viewModel.searchText.isEmpty {
                    noResultsView
                } else {
                    defaultView
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSearchFieldFocused = true
        }
    }

    // MARK: - Search Header
    private var searchHeader: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))

                TextField("Search Marvel characters...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        viewModel.search()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Suggestions
            if !viewModel.suggestions.isEmpty {
                suggestionsView
            }
        }
        .background(Color.black)
    }

    // MARK: - Suggestions View
    private var suggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        viewModel.selectSuggestion(suggestion)
                    }) {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.3))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }

    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 10) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SearchFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            icon: filter.icon,
                            isSelected: viewModel.selectedFilter == filter,
                            action: {
                                viewModel.updateFilter(filter)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Sort Options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Text("Sort by:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ForEach(SortOption.allCases, id: \.self) { option in
                        SortChip(
                            title: option.title,
                            icon: option.icon,
                            isSelected: viewModel.sortOption == option,
                            action: {
                                viewModel.updateSortOption(option)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 5)
        .background(Color.black)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                .scaleEffect(1.5)
            Text("Searching...")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top)
            Spacer()
        }
    }

    // MARK: - Search Results View
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredResults) { character in
                    SearchResultCard(character: character)
                        .onTapGesture {
                            onCharacterSelected?(character)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Results Found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Try searching with different keywords")
                .font(.body)
                .foregroundColor(.gray)

            Spacer()
        }
    }

    // MARK: - Default View (Recent Searches)
    private var defaultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recent Searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()

                            Button("Clear") {
                                viewModel.clearRecentSearches()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)

                        ForEach(Array(viewModel.recentSearches.enumerated()), id: \.offset) { index, search in
                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text(search)
                                    .foregroundColor(.white)

                                Spacer()

                                Button(action: {
                                    viewModel.removeRecentSearch(at: index)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.searchText = search
                                viewModel.search()
                            }
                        }
                    }
                    .padding(.top, 20)
                }

                // Popular Characters
                popularCharactersSection
            }
        }
    }

    // MARK: - Popular Characters Section
    private var popularCharactersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Popular Characters")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(popularCharacters, id: \.self) { name in
                        PopularCharacterChip(name: name) {
                            viewModel.searchText = name
                            viewModel.search()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 20)
    }

    private let popularCharacters = [
        "Spider-Man",
        "Iron Man",
        "Captain America",
        "Thor",
        "Hulk",
        "Black Widow",
        "Doctor Strange",
        "Black Panther",
        "Wolverine",
        "Deadpool"
    ]
}

// MARK: - Supporting Views
struct SearchResultCard: View {
    let character: Character

    var body: some View {
        HStack(spacing: 15) {
            // Character Image
            AsyncImage(url: character.thumbnail.secureUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                default:
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
            }

            // Character Info
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label("\(character.comics.available)", systemImage: "book.fill")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Label("\(character.series.available)", systemImage: "tv.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.red : Color.white.opacity(0.1))
            )
        }
    }
}

struct SortChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .red : .gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct PopularCharacterChip: View {
    let name: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red.opacity(0.6),
                                    Color.red.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
    }
}
