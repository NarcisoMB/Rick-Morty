import XCTest
import CoreData
@testable import R_M

final class CharacterRepositoryTests: XCTestCase {
    private var httpClient: MockHTTPClient!
    private var persistence: PersistenceController!
    private var local: CharacterLocalDataSource!
    private var sut: CharacterRepository!

    override func setUp() {
        super.setUp()
        httpClient = MockHTTPClient()
        persistence = PersistenceController(inMemory: true)
        local = CharacterLocalDataSource(container: persistence.container)
        sut = CharacterRepository(client: httpClient, local: local)
    }

    // MARK: Cache hit

    func test_getCharacters_returnsCacheWhenAvailable() async throws {
        let cached = [Character.mock(id: 1), Character.mock(id: 2, name: "Morty Smith")]
        try insertCharacters(cached, page: 1, into: persistence.container.viewContext)

        let result = try await sut.getCharacters(page: 1, forceRefresh: false)

        XCTAssertEqual(result.characters.count, 2)
        XCTAssertTrue(httpClient.requestedEndpoints.isEmpty, "Network must not be called on cache hit")
    }

    // MARK: Network fetch

    func test_getCharacters_fetchesNetworkWhenCacheEmpty() async throws {
        let chars = [Character.mock(id: 10)]
        httpClient.responseData = makeResponseData(characters: chars, hasNextPage: true, totalPages: 42)

        let result = try await sut.getCharacters(page: 1, forceRefresh: false)

        XCTAssertEqual(result.characters.count, 1)
        XCTAssertEqual(result.characters.first?.id, 10)
        XCTAssertFalse(httpClient.requestedEndpoints.isEmpty)
    }

    func test_getCharacters_forceRefreshBypasesCache() async throws {
        let cachedChars = [Character.mock(id: 1)]
        try insertCharacters(cachedChars, page: 1, into: persistence.container.viewContext)

        let networkChars = [Character.mock(id: 99, name: "Evil Morty")]
        httpClient.responseData = makeResponseData(characters: networkChars, hasNextPage: false, totalPages: 1)

        let result = try await sut.getCharacters(page: 1, forceRefresh: true)

        XCTAssertEqual(result.characters.first?.id, 99, "Force refresh should return network data, not cache")
        XCTAssertFalse(result.hasNextPage)
    }

    func test_getCharacters_hasNextPageReflectsNetworkResponse() async throws {
        httpClient.responseData = makeResponseData(characters: [.mock()], hasNextPage: false, totalPages: 1)

        let result = try await sut.getCharacters(page: 1, forceRefresh: false)

        XCTAssertFalse(result.hasNextPage)
        XCTAssertEqual(result.totalPages, 1)
    }

    // MARK: Fallback to cache

    func test_getCharacters_fallsBackToCacheOnNetworkError() async throws {
        let cached = [Character.mock(id: 7)]
        try insertCharacters(cached, page: 1, into: persistence.container.viewContext)
        httpClient.error = NetworkError.serverError(503)

        let result = try await sut.getCharacters(page: 1, forceRefresh: false)

        XCTAssertEqual(result.characters.first?.id, 7, "Should return cached data when network fails")
    }

    func test_getCharacters_throwsWhenNetworkFailsAndNoCacheExists() async {
        httpClient.error = NetworkError.serverError(503)

        do {
            _ = try await sut.getCharacters(page: 1, forceRefresh: false)
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
