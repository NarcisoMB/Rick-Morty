import XCTest
@testable import R_M

final class NetworkErrorTests: XCTestCase {

    // MARK: isRetryable

    func test_serverError_4xx_notRetryable() {
        for code in [400, 401, 403, 404, 422, 429] {
            XCTAssertFalse(NetworkError.serverError(code).isRetryable, "4xx \(code) should not be retryable")
        }
    }

    func test_serverError_5xx_isRetryable() {
        for code in [500, 502, 503, 504] {
            XCTAssertTrue(NetworkError.serverError(code).isRetryable, "5xx \(code) should be retryable")
        }
    }

    func test_decodingFailed_notRetryable() {
        let error = NetworkError.decodingFailed(URLError(.cannotDecodeContentData))
        XCTAssertFalse(error.isRetryable)
    }

    func test_invalidURL_notRetryable() {
        XCTAssertFalse(NetworkError.invalidURL.isRetryable)
    }

    func test_unknown_isRetryable() {
        let error = NetworkError.unknown(URLError(.timedOut))
        XCTAssertTrue(error.isRetryable)
    }
}
