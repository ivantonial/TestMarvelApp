import CharacterDetail
import CharacterList
import ComicsList
import Core
import MarvelAPI
import Networking
import SwiftUI

@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public var navigationPath = NavigationPath()

    private let networkService: NetworkServiceProtocol
    private let marvelService: MarvelServiceProtocol

    // MARK: - Inicialização
    public init() {
        // ✅ Ler as chaves diretamente do Info.plist
        let publicKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PUBLIC_KEY") as? String ?? ""
        let privateKey = Bundle.main.object(forInfoDictionaryKey: "MARVEL_PRIVATE_KEY") as? String ?? ""

        // 📝 (Opcional) Logar as chaves para debug – remova em produção
        #if DEBUG
        print("🔑 Marvel Public Key:", publicKey.isEmpty ? "❌ Vazia" : "✅ Encontrada")
        print("🔐 Marvel Private Key:", privateKey.isEmpty ? "❌ Vazia" : "✅ Encontrada")
        #endif

        // ⚙️ Configurar Marvel API
        let config = MarvelAPIConfig(publicKey: publicKey, privateKey: privateKey)
        MarvelEndpoint.configure(with: config)

        // Inicializar serviços de rede e API
        self.networkService = NetworkService()
        self.marvelService = MarvelService(networkService: networkService)
    }

    // MARK: - Fluxo inicial
    @ViewBuilder
    public func start() -> some View {
        NavigationStack(
            path: Binding(
                get: { [weak self] in self?.navigationPath ?? NavigationPath() },
                set: { [weak self] in self?.navigationPath = $0 }
            )
        ) {
            self.characterListView()
                .navigationDestination(for: CharacterDestination.self) { destination in
                    switch destination {
                    case .detail(let character):
                        self.characterDetailView(character: character)
                    case .comics(let character):
                        self.comicsListView(character: character)
                    }
                }
        }
    }

    // MARK: - View Builders
    @ViewBuilder
    private func characterListView() -> some View {
        let useCase = FetchCharactersUseCase(service: marvelService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        CharacterListView(viewModel: viewModel) { character in
            self.navigate(to: .detail(character))
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
                self.navigate(to: .comics(character))
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

    // MARK: - Navegação
    public func navigate(to destination: CharacterDestination) {
        navigationPath.append(destination)
    }

    public func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    public func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
