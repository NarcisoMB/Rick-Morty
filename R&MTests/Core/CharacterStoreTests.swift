import XCTest
@testable import R_M

final class CharacterStoreTests: XCTestCase {
    private var sut: CharacterStore!

    override func setUp() {
        super.setUp()
        sut = CharacterStore()
    }

    func test_add_appendsNewCharacters() {
        sut.add([.mock(id: 1), .mock(id: 2)])
        XCTAssertEqual(sut.characters.count, 2)
    }

    func test_add_ignoresDuplicateIDs() {
        sut.add([.mock(id: 1)])
        sut.add([.mock(id: 1), .mock(id: 2)])
        XCTAssertEqual(sut.characters.count, 2)
    }

    func test_add_noopWhenEmpty() {
        sut.add([])
        XCTAssertTrue(sut.characters.isEmpty)
    }

    func test_replace_overwritesExistingCharacters() {
        sut.add([.mock(id: 1), .mock(id: 2)])
        sut.replace([.mock(id: 99)])
        XCTAssertEqual(sut.characters.count, 1)
        XCTAssertEqual(sut.characters.first?.id, 99)
    }

    func test_replace_withEmptyArrayClearsStore() {
        sut.add([.mock(id: 1)])
        sut.replace([])
        XCTAssertTrue(sut.characters.isEmpty)
    }

    func test_reset_clearsAllCharacters() {
        sut.add([.mock(id: 1), .mock(id: 2)])
        sut.reset()
        XCTAssertTrue(sut.characters.isEmpty)
    }

    func test_add_preservesOrder() {
        let chars = (1...5).map { Character.mock(id: $0) }
        sut.add(chars)
        XCTAssertEqual(sut.characters.map(\.id), [1, 2, 3, 4, 5])
    }
}
