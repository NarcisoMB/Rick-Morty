import XCTest
@testable import R_M

final class FavoritesManagerTests: XCTestCase {
    private var sut: FavoritesManager!
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "test_favorites_\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        sut = FavoritesManager(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func test_isFavorite_falseByDefault() {
        XCTAssertFalse(sut.isFavorite(.mock(id: 1)))
    }

    func test_toggle_addsCharacterToFavorites() {
        sut.toggle(.mock(id: 1))
        XCTAssertTrue(sut.isFavorite(.mock(id: 1)))
        XCTAssertEqual(sut.favorites.count, 1)
    }

    func test_toggle_removesCharacterWhenAlreadyFavorite() {
        let char = Character.mock(id: 1)
        sut.toggle(char)
        sut.toggle(char)
        XCTAssertFalse(sut.isFavorite(char))
        XCTAssertTrue(sut.favorites.isEmpty)
    }

    func test_toggle_matchesByID() {
        sut.toggle(.mock(id: 5, name: "Rick"))
        XCTAssertTrue(sut.isFavorite(.mock(id: 5, name: "Rick Sanchez")))
    }

    func test_favorites_persistsThroughNewInstance() {
        sut.toggle(.mock(id: 3))

        let newInstance = FavoritesManager(userDefaults: userDefaults)
        XCTAssertTrue(newInstance.isFavorite(.mock(id: 3)), "Favorites should survive app restart")
    }

    func test_favorites_multipleFavoritesTrackedIndependently() {
        sut.toggle(.mock(id: 1))
        sut.toggle(.mock(id: 2))
        sut.toggle(.mock(id: 3))
        sut.toggle(.mock(id: 2))

        XCTAssertTrue(sut.isFavorite(.mock(id: 1)))
        XCTAssertFalse(sut.isFavorite(.mock(id: 2)))
        XCTAssertTrue(sut.isFavorite(.mock(id: 3)))
        XCTAssertEqual(sut.favorites.count, 2)
    }
}

