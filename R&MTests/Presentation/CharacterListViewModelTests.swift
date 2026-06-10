import XCTest
@testable import R_M

final class CharacterListViewModelTests: XCTestCase {
    private var repo: MockCharacterRepository!
    private var store: CharacterStore!
    private var sut: CharacterListViewModel!

    override func setUp() {
        super.setUp()
        repo = MockCharacterRepository()
        store = CharacterStore()
        sut = CharacterListViewModel(
            useCase: GetCharactersUseCase(repository: repo),
            store: store
        )
    }

    override func tearDown() {
        store.reset()
        super.tearDown()
    }

    // MARK: Initial load

    func test_loadCharacters_populatesCharactersOnSuccess() async {
        let chars = [Character.mock(id: 1), Character.mock(id: 2)]
        repo.stubbedPages[1] = .mock(characters: chars, totalPages: 10)

        await sut.loadCharacters()

        XCTAssertEqual(sut.characters.count, 2)
        XCTAssertNil(sut.alertError)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadCharacters_setsAlertErrorOnFailure() async {
        repo.error = NetworkError.serverError(500)

        await sut.loadCharacters()

        XCTAssertNotNil(sut.alertError)
        XCTAssertTrue(sut.characters.isEmpty)
    }

    func test_loadCharacters_ignoresSecondCallWhileNotEmpty() async {
        repo.stubbedPages[1] = .mock(characters: [.mock(id: 1)])
        await sut.loadCharacters()
        let firstCount = sut.characters.count

        repo.stubbedPages[1] = .mock(characters: [.mock(id: 2), .mock(id: 3)])
        await sut.loadCharacters()

        XCTAssertEqual(sut.characters.count, firstCount, "Second call should be no-op when characters already loaded")
        XCTAssertEqual(repo.callCount, 1)
    }

    func test_loadCharacters_addsCharactersToStore() async {
        let chars = [Character.mock(id: 42)]
        repo.stubbedPages[1] = .mock(characters: chars)

        await sut.loadCharacters()

        XCTAssertTrue(store.characters.contains(where: { $0.id == 42 }))
    }

    // MARK: Pagination

    func test_loadNextPageIfNeeded_appendsNextPage() async {
        let page1 = [Character.mock(id: 1)]
        let page2 = [Character.mock(id: 2), Character.mock(id: 3)]
        repo.stubbedPages[1] = .mock(characters: page1, hasNextPage: true, totalPages: 2)
        repo.stubbedPages[2] = .mock(characters: page2, hasNextPage: false, totalPages: 2)

        await sut.loadCharacters()
        await sut.loadNextPageIfNeeded(currentItem: sut.characters.last!)

        XCTAssertEqual(sut.characters.count, 3)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func test_loadNextPageIfNeeded_doesNotLoadWhenNotLastItem() async {
        let chars = [Character.mock(id: 1), Character.mock(id: 2)]
        repo.stubbedPages[1] = .mock(characters: chars, hasNextPage: true)
        await sut.loadCharacters()

        await sut.loadNextPageIfNeeded(currentItem: chars[0])

        XCTAssertEqual(repo.callCount, 1, "Should not paginate when item is not the last")
    }

    // MARK: Filtering

    func test_filteredCharacters_filtersBySearchText() async {
        repo.stubbedPages[1] = .mock(characters: [
            .mock(id: 1, name: "Rick Sanchez"),
            .mock(id: 2, name: "Morty Smith")
        ])
        await sut.loadCharacters()

        sut.searchText = "rick"

        XCTAssertEqual(sut.filteredCharacters.count, 1)
        XCTAssertEqual(sut.filteredCharacters.first?.name, "Rick Sanchez")
    }

    func test_filteredCharacters_filtersByStatus() async {
        repo.stubbedPages[1] = .mock(characters: [
            .mock(id: 1, name: "Rick", status: "Alive"),
            .mock(id: 2, name: "Morty", status: "Dead")
        ])
        await sut.loadCharacters()

        sut.filterStatus = "Dead"

        XCTAssertEqual(sut.filteredCharacters.count, 1)
        XCTAssertEqual(sut.filteredCharacters.first?.status, "Dead")
    }

    func test_filteredCharacters_returnsAllWhenNoFilter() async {
        repo.stubbedPages[1] = .mock(characters: [.mock(id: 1), .mock(id: 2), .mock(id: 3)])
        await sut.loadCharacters()

        XCTAssertEqual(sut.filteredCharacters.count, 3)
    }

    func test_hasActiveFilter_trueWhenStatusSet() async {
        sut.filterStatus = "Alive"
        XCTAssertTrue(sut.hasActiveFilter)
    }

    func test_hasActiveFilter_falseByDefault() {
        XCTAssertFalse(sut.hasActiveFilter)
    }
}
