//
//  CharacterListView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

//import SwiftUI
//import MarvelAPI
//import DesignSystem
//import Core
//
//public struct CharacterListView: View {
//    @StateObject private var viewModel: CharacterListViewModel
//    private let onCharacterSelected: ((Character) -> Void)?
//
//    public init(
//        viewModel: CharacterListViewModel,
//        onCharacterSelected: ((Character) -> Void)? = nil
//    ) {
//        self._viewModel = StateObject(wrappedValue: viewModel)
//        self.onCharacterSelected = onCharacterSelected
//    }
//
//    public var body: some View {
//        ZStack {
//            Color.black
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Header compacto
//                VStack(spacing: 10) {
//                    Text("Marvel Heroes")
//                        .font(.system(size: 34, weight: .bold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal)
//
//                    // Barra de busca
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//
//                        TextField("Buscar personagem", text: $viewModel.searchText)
//                            .foregroundColor(.white)
//                            .autocorrectionDisabled()
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 10)
//                    .background(Color.white.opacity(0.1))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                }
//                .padding(.top, 10) // Pouco espaço do topo
//                .padding(.bottom, 10)
//                .background(Color.black)
//
//                // Conteúdo principal
//                if viewModel.isLoading && viewModel.characters.isEmpty {
//                    Spacer()
//                    LoadingView(model: LoadingViewModel(message: "Carregando heróis..."))
//                    Spacer()
//                } else if let error = viewModel.error, viewModel.characters.isEmpty {
//                    Spacer()
//                    ErrorView(model: ErrorViewModel(
//                        message: error.localizedDescription,
//                        retryAction: viewModel.refresh
//                    ))
//                    Spacer()
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: gridColumns(), spacing: 16) {
//                            ForEach(viewModel.characterCardModels, id: \.id) { cardModel in
//                                CharacterCardView(model: cardModel)
//                                    .onTapGesture {
//                                        if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
//                                            onCharacterSelected?(character)
//                                        }
//                                    }
//                                    .onAppear {
//                                        if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
//                                            viewModel.loadMoreIfNeeded(currentCharacter: character)
//                                        }
//                                    }
//                            }
//
//                            if viewModel.isLoading && !viewModel.characters.isEmpty {
//                                ProgressView()
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.vertical, 10)
//                    }
//                    .refreshable {
//                        await refreshData()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            if viewModel.characters.isEmpty {
//                viewModel.loadInitialData()
//            }
//        }
//    }
//
//    private func gridColumns() -> [GridItem] {
//        [
//            GridItem(.flexible(), spacing: 16),
//            GridItem(.flexible(), spacing: 16)
//        ]
//    }
//
//    private func refreshData() async {
//        viewModel.refresh()
//    }
//}


// Mark: - Character List View Search Floating

//
//  CharacterListView.swift
//  CharacterList
//
//  Created by Ivan Tonial IP.TV on 07/10/25.
//

//import SwiftUI
//import MarvelAPI
//import DesignSystem
//import Core
//
//public struct CharacterListView: View {
//    @StateObject private var viewModel: CharacterListViewModel
//    private let onCharacterSelected: ((Character) -> Void)?
//
//    // ✅ Estado para controlar se a barra de busca está expandida
//    @State private var isSearching = false
//
//    public init(
//        viewModel: CharacterListViewModel,
//        onCharacterSelected: ((Character) -> Void)? = nil
//    ) {
//        self._viewModel = StateObject(wrappedValue: viewModel)
//        self.onCharacterSelected = onCharacterSelected
//    }
//
//    public var body: some View {
//        ZStack {
//            // Fundo preto
//            Color.black
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // ✅ Header fixo no topo - CENTRALIZADO
//                headerView
//                    .background(Color.black)
//                    .zIndex(1)
//
//                // Conteúdo principal
//                if viewModel.isLoading && viewModel.characters.isEmpty {
//                    Spacer()
//                    LoadingView(model: LoadingViewModel(message: "Carregando heróis..."))
//                    Spacer()
//                } else if let error = viewModel.error, viewModel.characters.isEmpty {
//                    Spacer()
//                    ErrorView(model: ErrorViewModel(
//                        message: error.localizedDescription,
//                        retryAction: viewModel.refresh
//                    ))
//                    Spacer()
//                } else {
//                    contentScrollView
//                }
//            }
//
//            // ✅ Barra de busca FLUTUANTE
//            VStack {
//                Spacer()
//                floatingSearchBar
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 30)
//            }
//        }
//        .onAppear {
//            if viewModel.characters.isEmpty {
//                viewModel.loadInitialData()
//            }
//        }
//    }
//
//    // MARK: - Header View (Título Centralizado)
//    private var headerView: some View {
//        VStack(spacing: 0) {
//            Text("Marvel Heroes")
//                .font(.system(size: 34, weight: .bold))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .center) // ✅ Centralizado
//                .padding(.horizontal)
//                .padding(.top, 10)
//                .padding(.bottom, 15)
//        }
//    }
//
//    // MARK: - Conteúdo Scrollável
//    private var contentScrollView: some View {
//        ScrollView {
//            LazyVGrid(columns: gridColumns(), spacing: 16) {
//                ForEach(viewModel.characterCardModels, id: \.id) { cardModel in
//                    CharacterCardView(model: cardModel)
//                        .onTapGesture {
//                            if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
//                                onCharacterSelected?(character)
//                            }
//                        }
//                        .onAppear {
//                            if let character = viewModel.filteredCharacters.first(where: { $0.id == cardModel.id }) {
//                                viewModel.loadMoreIfNeeded(currentCharacter: character)
//                            }
//                        }
//                }
//
//                if viewModel.isLoading && !viewModel.characters.isEmpty {
//                    ProgressView()
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 10)
//            .padding(.bottom, 80) // ✅ Espaço para não sobrepor a barra de busca
//        }
//        .refreshable {
//            await refreshData()
//        }
//    }
//
//    // MARK: - Barra de Busca Flutuante (Sempre Expandida)
//    private var floatingSearchBar: some View {
//        HStack(spacing: 12) {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.white) // ✅ MUDEI: de .gray para .white para melhor contraste
//                .font(.system(size: 18))
//
//            TextField("Buscar personagem", text: $viewModel.searchText)
//                .foregroundColor(.white)
//                .autocorrectionDisabled()
//                .textInputAutocapitalization(.never)
//
//            if !viewModel.searchText.isEmpty {
//                Button(action: {
//                    viewModel.searchText = ""
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.white.opacity(0.8)) // ✅ MUDEI: para melhor contraste
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//        .background(
//            RoundedRectangle(cornerRadius: 25)
//                .fill(Color.red.opacity(0.7)) // ✅ MUDEI: de white.opacity(0.15) para red.opacity(0.7)
//                .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 5) // ✅ MUDEI: sombra vermelha
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(Color.red.opacity(0.8), lineWidth: 1.5) // ✅ MUDEI: borda vermelha mais forte
//        )
//    }
//
//    private func gridColumns() -> [GridItem] {
//        [
//            GridItem(.flexible(), spacing: 16),
//            GridItem(.flexible(), spacing: 16)
//        ]
//    }
//
//    private func refreshData() async {
//        viewModel.refresh()
//    }
//}

// Mark: - Character List View Search Compact Header
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

    // Estado para controlar se a barra de busca está expandida
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
            // Fundo preto
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header fixo no topo - CENTRALIZADO
                headerView
                    .background(Color.black)
                    .zIndex(1)

                // Conteúdo principal
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    Spacer()
                    LoadingView(model: LoadingViewModel(message: "Carregando heróis..."))
                    Spacer()
                } else if let error = viewModel.error, viewModel.characters.isEmpty {
                    Spacer()
                    ErrorView(model: ErrorViewModel(
                        message: error.localizedDescription,
                        retryAction: viewModel.refresh
                    ))
                    Spacer()
                } else {
                    contentScrollView
                }
            }

            // Barra de busca FLUTUANTE com animação
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

    // MARK: - Header View (Título Centralizado)
    private var headerView: some View {
        VStack(spacing: 0) {
            Text("Marvel Heroes")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
        }
    }

    // MARK: - Conteúdo Scrollável
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

    // MARK: - Barra de Busca Flutuante com Expansão Animada
    private var floatingSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white) // ✅ MUDEI: sempre branco para melhor contraste
                .font(.system(size: 18))

            if isSearching {
                TextField("Buscar personagem", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .transition(.move(edge: .trailing).combined(with: .opacity))

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8)) // ✅ MUDEI: para melhor contraste
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isSearching = false
                        viewModel.searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }) {
                    Text("Cancelar")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                Text("Buscar")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: isSearching ? 25 : 30)
                .fill(Color.red.opacity(isSearching ? 0.75 : 0.7)) // ✅ MUDEI: vermelho Marvel
                .shadow(color: .red.opacity(0.5), radius: 15, x: 0, y: 5) // ✅ MUDEI: sombra vermelha
        )
        .overlay(
            RoundedRectangle(cornerRadius: isSearching ? 25 : 30)
                .stroke(Color.red.opacity(0.8), lineWidth: 1.5) // ✅ MUDEI: borda vermelha
        )
        .onTapGesture {
            if !isSearching {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isSearching = true
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearching)
    }
    
    private func gridColumns() -> [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    private func refreshData() async {
        viewModel.refresh()
    }
}
