// The Swift Programming Language
// https://docs.swift.org/swift-book

import CharacterDetail
import CharacterList
import ComicsList
import Core
import Favorites
import MarvelAPI
import Networking
import Search
import Settings
import SwiftUI

@MainActor
public final class AppCoordinator: ObservableObject {
    // MARK: - Tab Management
    @Published public var selectedTab: AppTab = .characters

    // MARK: - Navigation Paths for each tab
    @Published public var charactersPath = NavigationPath()
    @Published public var searchPath = NavigationPath()
    @Published public var favoritesPath = NavigationPath()
    @Published public var settingsPath = NavigationPath()

    // MARK: - Services
    private let networkService: NetworkServiceProtocol
    private let marvelService: MarvelServiceProtocol

    // MARK: - View Models (mantém estado entre navegações)
    private var searchViewModel: SearchViewModel?
    private var favoritesViewModel: FavoritesViewModel?
    private var settingsViewModel: SettingsViewModel?

    // MARK: - Inicialização
    public init() {
        // ✅ Ler as chaves diretamente do Info.plist
        let publicKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PUBLIC_KEY") as? String ?? ""
        let privateKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PRIVATE_KEY") as? String ?? ""

        // 🔐 (Opcional) Logar as chaves para debug – remova em produção
        #if DEBUG
        print("🔑 Marvel Public Key:", publicKey.isEmpty ? "⌛ Vazia" : "✅ Encontrada")
        print("🔐 Marvel Private Key:", privateKey.isEmpty ? "⌛ Vazia" : "✅ Encontrada")
        #endif

        // ⚙️ Configurar Marvel API
        let config = MarvelAPIConfig(publicKey: publicKey, privateKey: privateKey)
        MarvelEndpoint.configure(with: config)

        // Inicializar serviços de rede e API
        self.networkService = NetworkService()
        self.marvelService = MarvelService(networkService: networkService)

        // Inicializar ViewModels compartilhados
        initializeViewModels()
    }
    
    // MARK: - Inicialização dos ViewModels
    private func initializeViewModels() {
        // Search ViewModel - os use cases agora estão no módulo Search
        self.searchViewModel = Search.SearchViewModel(
            marvelService: marvelService  // Passa só o service
        )

        // Favorites ViewModel
        self.favoritesViewModel = FavoritesViewModel(favoritesService: FavoritesService.shared)

        // Settings ViewModel
        self.settingsViewModel = SettingsViewModel()
    }

    // MARK: - Main App View
    @ViewBuilder
    public func start() -> some View {
        TabView(
            selection: Binding(
                get: { self.selectedTab },
                set: { self.selectedTab = $0 }
            )
        ) {
            // Tab 1: Characters
            NavigationStack(
                path: Binding(
                    get: { self.charactersPath },
                    set: { self.charactersPath = $0 }
                )
            ) {
                characterListView()
                    .navigationDestination(for: CharacterDestination.self) { destination in
                        switch destination {
                        case .detail(let character):
                            self.characterDetailView(character: character)
                        case .comics(let character):
                            self.comicsListView(character: character)
                        }
                    }
            }
            .tabItem {
                Label("Heroes", systemImage: "person.3.fill")
            }
            .tag(AppTab.characters)

            // Tab 2: Search
            NavigationStack(
                path: Binding(
                    get: { self.searchPath },
                    set: { self.searchPath = $0 }
                )
            ) {
                searchView()
                    .navigationDestination(for: CharacterDestination.self) { destination in
                        switch destination {
                        case .detail(let character):
                            self.characterDetailView(character: character)
                        case .comics(let character):
                            self.comicsListView(character: character)
                        }
                    }
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(AppTab.search)

            // Tab 3: Favorites
            NavigationStack(
                path: Binding(
                    get: { self.favoritesPath },
                    set: { self.favoritesPath = $0 }
                )
            ) {
                favoritesView()
                    .navigationDestination(for: CharacterDestination.self) { destination in
                        switch destination {
                        case .detail(let character):
                            self.characterDetailView(character: character)
                        case .comics(let character):
                            self.comicsListView(character: character)
                        }
                    }
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(AppTab.favorites)

            // Tab 4: Settings
            NavigationStack(
                path: Binding(
                    get: { self.settingsPath },
                    set: { self.settingsPath = $0 }
                )
            ) {
                settingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(AppTab.settings)
        }
        .tint(.red) // Cor de destaque da TabBar
    }

    // MARK: - View Builders
    @ViewBuilder
    private func characterListView() -> some View {
        let fetchUseCase = FetchCharactersUseCase(service: marvelService)
        let viewModel = CharacterListViewModel(
                    fetchCharactersUseCase: fetchUseCase,
                    marvelService: marvelService
                )

        CharacterListView(viewModel: viewModel) { character in
            self.navigateToCharacter(character, in: .characters)
        }
    }

    @ViewBuilder
    private func searchView() -> some View {
        if let viewModel = searchViewModel {
            SearchView(
                viewModel: viewModel,
                onCharacterSelected: { character in
                    self.navigateToCharacter(character, in: .search)
                },
                onComicSelected: { comic in
                    // Implementar navegação para detalhes do quadrinho se necessário
                    print("Comic selecionado: \(comic.title)")
                }
            )
        }
    }

    @ViewBuilder
    private func favoritesView() -> some View {
        if let viewModel = favoritesViewModel {
            FavoritesView(viewModel: viewModel) { character in
                self.navigateToCharacter(character, in: .favorites)
            }
        }
    }

    @ViewBuilder
    private func settingsView() -> some View {
        if let viewModel = settingsViewModel {
            SettingsView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private func characterDetailView(character: Character) -> some View {
        let fetchDetailUseCase = FetchCharacterDetailUseCase(service: marvelService)
        let fetchComicsUseCase = FetchCharacterComicsUseCase(service: marvelService)

        let viewModel = CharacterDetailViewModel(
            character: character,
            fetchCharacterDetailUseCase: fetchDetailUseCase,
            fetchCharacterComicsUseCase: fetchComicsUseCase,
            favoritesService: nil  // Pode adicionar FavoritesService mais tarde
        )

        CharacterDetailView(
            viewModel: viewModel,
            onComicsSelected: {
                self.navigateToComics(for: character)
            }
        )
    }

    @ViewBuilder
    private func comicsListView(character: Character) -> some View {
        let fetchComicsUseCase = FetchCharacterComicsUseCase(service: marvelService)
        let viewModel = ComicsListViewModel(
            character: character,
            fetchCharacterComicsUseCase: fetchComicsUseCase
        )

        ComicsListView(viewModel: viewModel)
    }

    // MARK: - Navigation Methods
    public func navigateToCharacter(_ character: Character, in tab: AppTab) {
        switch tab {
        case .characters:
            charactersPath.append(CharacterDestination.detail(character))
        case .search:
            searchPath.append(CharacterDestination.detail(character))
        case .favorites:
            favoritesPath.append(CharacterDestination.detail(character))
        case .settings:
            break // Settings não navega para personagens
        }
    }

    public func navigateToComics(for character: Character) {
        // Detecta qual tab está ativa e navega na path correta
        switch selectedTab {
        case .characters:
            charactersPath.append(CharacterDestination.comics(character))
        case .search:
            searchPath.append(CharacterDestination.comics(character))
        case .favorites:
            favoritesPath.append(CharacterDestination.comics(character))
        case .settings:
            break
        }
    }

    public func navigateBack() {
        switch selectedTab {
        case .characters:
            if !charactersPath.isEmpty {
                charactersPath.removeLast()
            }
        case .search:
            if !searchPath.isEmpty {
                searchPath.removeLast()
            }
        case .favorites:
            if !favoritesPath.isEmpty {
                favoritesPath.removeLast()
            }
        case .settings:
            if !settingsPath.isEmpty {
                settingsPath.removeLast()
            }
        }
    }

    public func navigateToRoot(in tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        switch targetTab {
        case .characters:
            charactersPath.removeLast(charactersPath.count)
        case .search:
            searchPath.removeLast(searchPath.count)
        case .favorites:
            favoritesPath.removeLast(favoritesPath.count)
        case .settings:
            settingsPath.removeLast(settingsPath.count)
        }
    }
}

// MARK: - App Tabs Enum
public enum AppTab: String, CaseIterable {
    case characters = "Heroes"
    case search = "Search"
    case favorites = "Favorites"
    case settings = "Settings"
}

