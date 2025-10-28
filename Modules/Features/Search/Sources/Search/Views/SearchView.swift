//
//  SearchView.swift
//  Search
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import CharacterList
import ComicsList
import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFieldFocused: Bool
    private let onCharacterSelected: ((Character) -> Void)?
    private let onComicSelected: ((Comic) -> Void)?

    public init(
        viewModel: SearchViewModel,
        onCharacterSelected: ((Character) -> Void)? = nil,
        onComicSelected: ((Comic) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onCharacterSelected = onCharacterSelected
        self.onComicSelected = onComicSelected
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search Type Selector
                searchTypeSelector

                // Search Header
                searchHeader

                // Filter Pills
                if viewModel.hasResults {
                    filterSection
                }

                // Main Content
                mainContent
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSearchFieldFocused = true
        }
    }

    // MARK: - Search Type Selector
    private var searchTypeSelector: some View {
        HStack(spacing: 0) {
            ForEach(SearchType.allCases, id: \.self) { type in
                Button(action: {
                    viewModel.switchSearchType(type)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.system(size: 20))

                        Text(type.rawValue)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(viewModel.searchType == type ? .black : .white)
                    .background(
                        viewModel.searchType == type ?
                        Color.red : Color.clear
                    )
                }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Main Content Router
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isSearching {
            loadingView
        } else if viewModel.hasResults {
            resultsView
        } else if !viewModel.searchText.isEmpty {
            noResultsView
        } else {
            defaultView
        }
    }

    // MARK: - Results View Router
    @ViewBuilder
    private var resultsView: some View {
        switch viewModel.searchType {
        case .characters:
            characterResultsView
        case .comics:
            comicResultsView
        }
    }

    // MARK: - Character Results
    private var characterResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredCharacters) { character in
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

    // MARK: - Comic Results
    private var comicResultsView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.filteredComics) { comic in
                    // Using the same ComicCardView from ComicsList module
                    ComicCardView(
                        model: ComicCardModel(from: comic),
                        onTap: {
                            onComicSelected?(comic)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
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
                        // Dismiss do teclado ao submeter
                        isSearchFieldFocused = false
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

    // MARK: - Suggestions View (CORRIGIDO COM DISMISS)
    private var suggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Usa enumerated() para ter um índice único ao invés do próprio texto
                ForEach(Array(viewModel.suggestions.enumerated()), id: \.offset) { index, suggestion in
                    Button(action: {
                        // Dismiss do teclado ao selecionar sugestão
                        isSearchFieldFocused = false
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.currentFilters, id: \.self) { filter in
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

                        ForEach(viewModel.recentSearches, id: \.self) { search in
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Text(search)
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Dismiss do teclado ao selecionar busca recente
                                isSearchFieldFocused = false
                                viewModel.selectRecentSearch(search)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Popular Characters
                popularCharactersSection
            }
            .padding(.top, 20)
        }
    }

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
                            // Dismiss do teclado ao selecionar personagem popular
                            isSearchFieldFocused = false
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

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .foregroundColor(.white)

                // CORREÇÃO: description é String não opcional
                if !character.description.isEmpty {
                    Text(character.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                HStack(spacing: 15) {
                    Label("\(character.comics.available)", systemImage: "book.fill")
                    Label("\(character.series.available)", systemImage: "tv.fill")
                }
                .font(.caption2)
                .foregroundColor(.red)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .black : .white)
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

struct PopularCharacterChip: View {
    let name: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
    }
}
