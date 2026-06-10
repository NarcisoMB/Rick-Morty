import XCTest
import CoreLocation
@testable import R_M

final class CharacterMapViewModelTests: XCTestCase {
    private var repo: MockCharacterRepository!
    private var store: CharacterStore!
    private var sut: CharacterMapViewModel!

    override func setUp() {
        super.setUp()
        repo = MockCharacterRepository()
        store = CharacterStore()
        sut = CharacterMapViewModel(
            useCase: GetCharactersUseCase(repository: repo),
            store: store
        )
    }

    override func tearDown() {
        store.reset()
        super.tearDown()
    }

    // MARK: Annotations

    func test_annotations_reflectsStoreCharacters() {
        store.add([.mock(id: 1), .mock(id: 2)])
        XCTAssertEqual(sut.annotations.count, 2)
    }

    func test_annotations_emptyWhenStoreEmpty() {
        XCTAssertTrue(sut.annotations.isEmpty)
    }

    func test_annotations_eachAnnotationMatchesCharacter() {
        let char = Character.mock(id: 5, name: "Birdperson")
        store.add([char])

        XCTAssertEqual(sut.annotations.first?.character.name, "Birdperson")
        XCTAssertEqual(sut.annotations.first?.id, 5)
    }

    // MARK: Load

    func test_load_fetchesWhenStoreEmpty() async {
        repo.stubbedPages[1] = .mock(characters: [.mock(id: 1)], hasNextPage: false)
        repo.stubbedPages[2] = .mock(characters: [], hasNextPage: false)
        repo.stubbedPages[3] = .mock(characters: [], hasNextPage: false)

        await sut.load()

        XCTAssertGreaterThan(repo.callCount, 0)
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_skipsWhenStoreNotEmpty() async {
        store.add([.mock(id: 1)])

        await sut.load()

        XCTAssertEqual(repo.callCount, 0, "Should not fetch when store already has characters")
    }

    // MARK: Coordinate generation

    func test_coordinate_isDeterministic() {
        let a = CharacterMapViewModel.coordinate(for: 42)
        let b = CharacterMapViewModel.coordinate(for: 42)
        XCTAssertEqual(a.latitude, b.latitude)
        XCTAssertEqual(a.longitude, b.longitude)
    }

    func test_coordinate_differsForDifferentIDs() {
        let c1 = CharacterMapViewModel.coordinate(for: 1)
        let c2 = CharacterMapViewModel.coordinate(for: 2)
        XCTAssertNotEqual(c1.latitude, c2.latitude)
    }

    func test_coordinate_withinValidRange() {
        for id in 1...50 {
            let coord = CharacterMapViewModel.coordinate(for: id)
            XCTAssertTrue(coord.latitude >= -90 && coord.latitude <= 90, "Latitude \(coord.latitude) out of range for id \(id)")
            XCTAssertTrue(coord.longitude >= -180 && coord.longitude <= 180, "Longitude \(coord.longitude) out of range for id \(id)")
        }
    }
}
