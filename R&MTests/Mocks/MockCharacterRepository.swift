@testable import R_M

final class MockCharacterRepository: CharacterRepositoryProtocol {
    var stubbedPages: [Int: CharacterPage] = [:]
    var error: Error?
    var callCount = 0
    var lastPage: Int?
    var lastForceRefresh: Bool?

    func getCharacters(page: Int, forceRefresh: Bool) async throws -> CharacterPage {
        callCount += 1
        lastPage = page
        lastForceRefresh = forceRefresh
        if let error { throw error }
        return stubbedPages[page] ?? CharacterPage(characters: [], hasNextPage: false, totalPages: 1)
    }
}
