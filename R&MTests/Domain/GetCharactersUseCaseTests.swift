import XCTest
@testable import R_M

final class GetCharactersUseCaseTests: XCTestCase {
    private var repo: MockCharacterRepository!
    private var sut: GetCharactersUseCase!

    override func setUp() {
        super.setUp()
        repo = MockCharacterRepository()
        sut = GetCharactersUseCase(repository: repo)
    }

    func test_execute_returnsPageFromRepository() async throws {
        let page = CharacterPage.mock(characters: [.mock(id: 1), .mock(id: 2)], totalPages: 5)
        repo.stubbedPages[1] = page

        let result = try await sut.execute(page: 1)

        XCTAssertEqual(result.characters.count, 2)
        XCTAssertEqual(result.totalPages, 5)
        XCTAssertEqual(repo.lastPage, 1)
        XCTAssertEqual(repo.lastForceRefresh, false)
    }

    func test_execute_forceRefreshPassedThrough() async throws {
        repo.stubbedPages[2] = .mock(hasNextPage: false)

        _ = try await sut.execute(page: 2, forceRefresh: true)

        XCTAssertEqual(repo.lastForceRefresh, true)
        XCTAssertEqual(repo.lastPage, 2)
    }

    func test_execute_propagatesRepositoryError() async {
        repo.error = NetworkError.serverError(500)

        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
