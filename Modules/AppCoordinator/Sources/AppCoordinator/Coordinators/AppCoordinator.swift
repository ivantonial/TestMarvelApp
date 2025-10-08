// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Core
import CharacterList
import MarvelAPI
import Networking

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

        // 🔍 (Opcional) Logar as chaves para debug — remova em produção
        print("🔑 Marvel Public Key:", publicKey.isEmpty ? "❌ Vazia" : "✅ Encontrada")
        print("🔒 Marvel Private Key:", privateKey.isEmpty ? "❌ Vazia" : "✅ Encontrada")

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
                .navigationDestination(for: CharacterDestination.self) { [weak self] destination in
                    switch destination {
                    case .detail(let character):
                        self?.characterDetailView(character: character)
                    case .comics(let character):
                        self?.comicsListView(character: character)
                    }
                }
        }
    }

    // MARK: - View Builders
    @ViewBuilder
    private func characterListView() -> some View {
        let useCase = FetchCharactersUseCase(service: marvelService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        CharacterListView(viewModel: viewModel) { [weak self] character in
            self?.navigate(to: .detail(character))
        }
    }

    @ViewBuilder
    private func characterDetailView(character: Character) -> some View {
        VStack {
            Text(character.name)
                .font(.largeTitle)
                .padding(.bottom, 8)

            AsyncImage(url: character.thumbnail.secureUrl)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(character.description.isEmpty ? "Sem descrição disponível." : character.description)
                .font(.body)
                .padding()

            Button("Ver Quadrinhos") { [weak self] in
                self?.navigate(to: .comics(character))
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle(character.name)
    }

    @ViewBuilder
    private func comicsListView(character: Character) -> some View {
        Text("Quadrinhos de \(character.name)")
            .font(.title)
            .padding()
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

// MARK: - Enum de Destinos
public enum CharacterDestination: Hashable {
    case detail(Character)
    case comics(Character)
}
