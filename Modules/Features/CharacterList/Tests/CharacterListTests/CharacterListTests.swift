import XCTest
import Testing
import Networking
@testable import CharacterList
@testable import MarvelAPI


// MARK: - Mock Service
final class MockMarvelService: MarvelServiceProtocol, @unchecked Sendable {
    var shouldThrowError = false
    var charactersToReturn: [Character] = []
    var characterToReturn: Character?
    var comicsToReturn: [Comic] = []

    func fetchCharacters(offset: Int, limit: Int) async throws -> [Character] {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        return charactersToReturn
    }

    func fetchCharacter(by id: Int) async throws -> Character {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        guard let character = characterToReturn else {
            throw NetworkError.noData
        }
        return character
    }

    func fetchCharacterComics(characterId: Int, offset: Int, limit: Int) async throws -> [Comic] {
        if shouldThrowError {
            throw NetworkError.serverError(500)
        }
        return comicsToReturn
    }
}

// MARK: - Fixtures
extension Character {
    static func fixture(
        id: Int = 1,
        name: String = "Spider-Man",
        description: String = "Friendly neighborhood Spider-Man",
        comicsAvailable: Int = 100
    ) -> Character {
        return Character(
            id: id,
            name: name,
            description: description,
            modified: "2023-01-01T00:00:00-0500",
            thumbnail: MarvelImage(path: "http://example.com/image", extension: "jpg"),
            resourceURI: "http://example.com/character/\(id)",
            comics: ComicList(
                available: comicsAvailable,
                collectionURI: "",
                items: [],
                returned: 0
            ),
            series: SeriesList(available: 0, collectionURI: "", items: [], returned: 0),
            stories: StoryList(available: 0, collectionURI: "", items: [], returned: 0),
            events: EventList(available: 0, collectionURI: "", items: [], returned: 0),
            urls: []
        )
    }
}

// MARK: - Tests using Swift Testing
@Suite("CharacterListViewModel Tests")
struct CharacterListViewModelTests {

    @Test("Should load characters successfully")
    @MainActor
    func testLoadCharactersSuccess() async {
        // Arrange
        let mockService = MockMarvelService()
        mockService.charactersToReturn = [
            Character.fixture(id: 1, name: "Spider-Man"),
            Character.fixture(id: 2, name: "Iron Man")
        ]

        let useCase = FetchCharactersUseCase(service: mockService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        // Act
        viewModel.loadInitialData()

        // Assert
        #expect(viewModel.characters.count == 2)
        #expect(viewModel.characters[0].name == "Spider-Man")
        #expect(viewModel.characters[1].name == "Iron Man")
        #expect(viewModel.error == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Should handle error when loading characters")
    @MainActor
    func testLoadCharactersError() async {
        // Arrange
        let mockService = MockMarvelService()
        mockService.shouldThrowError = true

        let useCase = FetchCharactersUseCase(service: mockService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        // Act
        viewModel.loadInitialData()

        // Assert
        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.error != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Should filter characters by search text")
    @MainActor
    func testFilterCharactersBySearchText() async {
        // Arrange
        let mockService = MockMarvelService()
        mockService.charactersToReturn = [
            Character.fixture(id: 1, name: "Spider-Man"),
            Character.fixture(id: 2, name: "Iron Man"),
            Character.fixture(id: 3, name: "Captain America")
        ]

        let useCase = FetchCharactersUseCase(service: mockService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        // Act
        viewModel.loadInitialData()
        viewModel.searchText = "man"

        // Assert
        #expect(viewModel.filteredCharacters.count == 2)
        #expect(viewModel.filteredCharacters[0].name == "Spider-Man")
        #expect(viewModel.filteredCharacters[1].name == "Iron Man")
    }

    @Test("Should convert characters to card models")
    @MainActor
    func testCharacterCardModels() async {
        // Arrange
        let mockService = MockMarvelService()
        mockService.charactersToReturn = [
            Character.fixture(id: 1, name: "Spider-Man", comicsAvailable: 150),
            Character.fixture(id: 2, name: "Iron Man", comicsAvailable: 200)
        ]

        let useCase = FetchCharactersUseCase(service: mockService)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)

        // Act
        viewModel.loadInitialData()

        // Assert
        let cardModels = viewModel.characterCardModels
        #expect(cardModels.count == 2)
        #expect(cardModels[0].name == "Spider-Man")
        #expect(cardModels[0].comicsCount == 150)
        #expect(cardModels[1].name == "Iron Man")
        #expect(cardModels[1].comicsCount == 200)
    }
}

// MARK: - XCTest UI Tests
class CharacterListUITests: XCTestCase {

    @MainActor
    func testCharacterListView() async {
        let app = XCUIApplication()
        app.launch()

        // Verificar se a navegação existe
        XCTAssertTrue(app.navigationBars["Marvel Heroes"].exists)

        // Aguardar carregamento dos personagens
        let firstCharacterCard = app.scrollViews.otherElements.buttons.firstMatch
        let exists = firstCharacterCard.waitForExistence(timeout: 10)
        XCTAssertTrue(exists)

        // Testar busca
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Spider")

            // Verificar se o filtro funciona
            let spiderManCard = app.staticTexts["Spider-Man"]
            XCTAssertTrue(spiderManCard.waitForExistence(timeout: 5))
        }
    }
}

