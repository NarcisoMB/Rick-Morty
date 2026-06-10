import Foundation
@testable import R_M

final class MockHTTPClient: HTTPClientProtocol {
    var responseData: Data = Data()
    var error: Error?
    var requestedEndpoints: [Endpoint] = []

    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        if let error { throw error }
        return try JSONDecoder().decode(T.self, from: responseData)
    }
}
