//
//  CharacterListView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

import Core
import DesignSystem
import MarvelAPI
import SwiftUI

public struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel
    private let onCharacterSelected: ((Character) -> Void)?

    @State private var isSearching = false

    public init(
        viewModel: CharacterListViewModel,
        onCharacterSelected: ((Character) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onCharacterSelected = onCharacterSelected
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .background(Color.black)
                    .zIndex(1)

                if viewModel.isLoading && viewModel.characters.isEmpty {
                    Spacer()
                    LoadingComponent(message: "Carregando heróis...")
                    Spacer()
                } else if let error = viewModel.error, viewModel.characters.isEmpty {
                    Spacer()
                    ErrorComponent(
                        message: error.localizedDescription,
                        retryAction: viewModel.refresh
                    )
                    Spacer()
                } else {
                    contentScrollView
                }
            }

            // Search bar flutuante
            VStack {
                Spacer()
                floatingSearchBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            if viewModel.characters.isEmpty {
                viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        Text("Marvel Heroes")
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            .padding(.bottom, 15)
    }

    // MARK: - Conteúdo
    private var contentScrollView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns(), spacing: 16) {
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
            .padding(.vertical, 10)
            .padding(.bottom, 100)
        }
        .refreshable {
            await refreshData()
        }
    }

    // MARK: - Search bar
    private var floatingSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .font(.system(size: 18))

            if isSearching {
                TextField("Buscar personagem", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Button("Cancelar") {
                    withAnimation(.spring()) {
                        isSearching = false
                        viewModel.searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
            } else {
                Text("Buscar")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: isSearching ? 25 : 30)
                .fill(Color.red.opacity(isSearching ? 0.75 : 0.7))
                .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: isSearching ? 25 : 30)
                .stroke(Color.red.opacity(0.8), lineWidth: 1.5)
        )
        .onTapGesture {
            if !isSearching {
                withAnimation(.spring()) { isSearching = true }
            }
        }
    }

    private func gridColumns() -> [GridItem] {
        [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    }

    private func refreshData() async {
        viewModel.refresh()
    }
}
