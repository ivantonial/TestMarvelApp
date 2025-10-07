//
//  CharacterListView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import SwiftUI
import MarvelAPI
import DesignSystem
import Core

public struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel
    private let onCharacterSelected: ((Character) -> Void)?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(
        viewModel: CharacterListViewModel,
        onCharacterSelected: ((Character) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onCharacterSelected = onCharacterSelected
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: gridColumns(for: geometry), spacing: 20) {
                        ForEach(viewModel.characterCardModels, id: \.id) { cardModel in
                            CharacterCardView(model: cardModel)
                                .onTapGesture {
                                    if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
                                        onCharacterSelected?(character)
                                    }
                                }
                                .onAppear {
                                    if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
                                        viewModel.loadMoreIfNeeded(currentCharacter: character)
                                    }
                                }
                        }

                        if viewModel.isLoading && !viewModel.characters.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12) // spacing below header
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    .scrollIndicators(.hidden)
                    .refreshable {
                        await refreshData()
                    }
                }
                .safeAreaInset(edge: .top) {
                    VStack(spacing: 12) {
                        Text("Marvel Heroes")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        searchBar
                    }
                    .padding(.horizontal)
                    .padding(.top, 8) // small breathing room from safe area
                    .padding(.bottom, 12)
                    .background(.black)
                }
            }
        }
        .task {
            if viewModel.characters.isEmpty {
                viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)

            TextField("Buscar personagem", text: $viewModel.searchText)
                .foregroundColor(.white)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.vertical, 8)
        }
        .frame(height: 40)
        .background(Color(white: 0.15))
        .cornerRadius(10)
    }

    // MARK: - Responsive Grid
    private func gridColumns(for geometry: GeometryProxy) -> [GridItem] {
        let isLandscape = geometry.size.width > geometry.size.height
        let columnCount = isLandscape ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }

    private func refreshData() async {
        viewModel.refresh()
    }
}
